import Foundation

/// Runtime accessor for the versioned offline content pack bundle.
///
/// Responsibilities:
/// - locate bundled pack
/// - decode manifest
/// - validate supported schema
/// - cache decoded content (no per-body decoding)
/// - return Sun/day records, modifiers, copy pools
///
/// The pack is immutable; no file writes occur.
///
/// Thread-safety (§33/34): all mutable state (_state + indexes) is guarded by a
/// single NSLock. Decoding happens outside the lock; publication (state+indexes)
/// happens atomically inside. Reads copy under lock. Indexes are immutable
/// snapshot after publication. Justifies @unchecked Sendable.
final class BundledContentPackRepository: @unchecked Sendable {
    enum State: Sendable {
        case notLoaded
        case loaded(CompiledContentPack)
        case failed(String)
    }

    static let shared = BundledContentPackRepository()

    private let bundle: Bundle
    private let subdirectory: String
    private let singleFileName: String

    private let lock = NSLock()
    private var _state: State = .notLoaded
    // Immutable snapshot built exactly once under lock after decode.
    private struct Indexes: Sendable {
        var sun: [String: SunDayRecord] = [:]
        var moon: [String: MoonModifier] = [:]
        var rising: [String: RisingModifier] = [:]
        var archetype: [String: ArchetypeModifier] = [:]
        var built: Bool = false
    }
    private var indexes = Indexes()

    init(
        bundle: Bundle = .main,
        subdirectory: String = "ContentPacks/v1",
        singleFileName: String = "contentPack"
    ) {
        self.bundle = bundle
        self.subdirectory = subdirectory
        self.singleFileName = singleFileName
    }

    /// Testing initializer with explicit bundle + file URL (bypasses Bundle lookup).
    init(bundle: Bundle, subdirectory: String, singleFileName: String, preload pack: CompiledContentPack) {
        self.bundle = bundle
        self.subdirectory = subdirectory
        self.singleFileName = singleFileName
        self._state = .loaded(pack)
        self.indexes = Self.makeIndexes(for: pack)
    }

    private static func makeIndexes(for pack: CompiledContentPack) -> Indexes {
        var s: [String: SunDayRecord] = [:]
        s.reserveCapacity(pack.sunRecords.count)
        for r in pack.sunRecords {
            s["\(r.dayKey)|\(r.sunSign)"] = r
        }
        return Indexes(
            sun: s,
            moon: Dictionary(uniqueKeysWithValues: pack.moonModifiers.map { ($0.moonSign, $0) }),
            rising: Dictionary(uniqueKeysWithValues: pack.risingModifiers.map { ($0.risingSign, $0) }),
            archetype: Dictionary(uniqueKeysWithValues: pack.archetypeModifiers.map { ($0.archetypeID, $0) }),
            built: true
        )
    }

    // MARK: - Public accessors (cached)

    var manifest: ContentPackManifest? {
        switch loadIfNeeded() {
        case .loaded(let pack): pack.manifest
        case .failed, .notLoaded: nil
        }
    }

    /// Lifecycle-aware availability (§26/27). Pilot exempt; production checks activeFrom/through inclusive (UTC).
    var isAvailable: Bool {
        guard case .loaded(let pack) = loadIfNeeded() else { return false }
        return pack.manifest.isActive(on: Date())
    }

    /// Raw loaded check ignoring lifecycle (for DEBUG inspector).
    var isLoadedIgnoringLifecycle: Bool {
        if case .loaded = loadIfNeeded() { return true }
        return false
    }

    /// Lifecycle status for DEBUG.
    var lifecycleStatus: (active: Bool, from: Date?, through: Date?)? {
        guard let m = manifest else { return nil }
        return (m.isActive(on: Date()), m.activeFrom, m.activeThrough)
    }

    func isActive(on date: Date) -> Bool {
        guard let m = manifest else { return false }
        return m.isActive(on: date)
    }

    var loadError: String? {
        if case .failed(let msg) = loadIfNeeded() { return msg }
        return nil
    }

    var pack: CompiledContentPack? {
        if case .loaded(let p) = loadIfNeeded() { return p }
        return nil
    }

    /// Pack disregarding lifecycle — for DEBUG / QA only.
    var rawPack: CompiledContentPack? {
        if case .loaded(let p) = loadIfNeededRaw() { return p }
        return nil
    }

    func sunRecord(dayKey: CanonicalDayKey, sunSign: WesternZodiacSign) -> SunDayRecord? {
        guard case .loaded = loadIfNeeded() else { return nil }
        lock.lock()
        let idx = indexes
        lock.unlock()
        return idx.sun["\(dayKey.key)|\(sunSign.rawValue)"]
    }

    func moonModifier(sign: WesternZodiacSign) -> MoonModifier? {
        guard case .loaded = loadIfNeeded() else { return nil }
        lock.lock()
        let v = indexes.moon[sign.rawValue]
        lock.unlock()
        return v
    }

    func risingModifier(sign: WesternZodiacSign) -> RisingModifier? {
        guard case .loaded = loadIfNeeded() else { return nil }
        lock.lock()
        let v = indexes.rising[sign.rawValue]
        lock.unlock()
        return v
    }

    func archetypeModifier(id: String) -> ArchetypeModifier? {
        guard case .loaded = loadIfNeeded() else { return nil }
        lock.lock()
        let v = indexes.archetype[id]
        lock.unlock()
        return v
    }

    var copyPools: CopyPools? {
        guard case .loaded(let pack) = loadIfNeeded() else { return nil }
        return pack.copyPools
    }

    /// Batch index for DEBUG: dayKey|sunSign -> batchID
    func batchID(dayKey: String, sunSign: String) -> String? {
        guard let pack = rawPack else { return nil }
        // If manifest batches declared ranges, map; else nil
        guard let batches = pack.manifest.batches else { return nil }
        for b in batches {
            // signs nil means all; else must contain sign
            if let signs = b.signs, !signs.contains(sunSign) { continue }
            if let range = b.dayKeyRange {
                // expects "MM-DD_MM-DD" or single
                let parts = range.split(separator: "_")
                if parts.count == 2 {
                    let start = String(parts[0]), end = String(parts[1])
                    // Use canonical ordering via all366
                    let all = CanonicalDayKey.all366.map(\.key)
                    guard let sIdx = all.firstIndex(of: start), let eIdx = all.firstIndex(of: end), let kIdx = all.firstIndex(of: dayKey) else { continue }
                    if kIdx >= sIdx && kIdx <= eIdx { return b.batchID }
                } else if parts.count == 1, String(parts[0]) == dayKey {
                    return b.batchID
                }
            } else {
                // No range => no mapping, skip
                continue
            }
        }
        return nil
    }

    /// Force reload (testing).
    func reload() {
        lock.lock()
        _state = .notLoaded
        indexes = Indexes()
        lock.unlock()
        _ = loadIfNeeded()
    }

    // MARK: - Loading

    /// Lifecycle-aware load. Returns .loaded only if pack passes manifest.isActive.
    private func loadIfNeeded() -> State {
        let raw = loadIfNeededRaw()
        guard case .loaded(let pack) = raw else { return raw }
        if pack.manifest.isActive(on: Date()) { return raw }
        // Inactive production pack → behave as unavailable (spec §27)
        // Do not mutate state to failed; keep raw but report as unavailable via isAvailable gate.
        // Callers check isAvailable, but pack accessors that use loadIfNeeded will now return failed-like.
        // To implement, return .failed for lifecycle-unaware callers, but keep rawPack for DEBUG.
        // We return .failed-like by mapping to unavailable signal; callers treat as nil.
        // Simulate unavailable by returning failed state proxy (so sunRecord returns nil).
        // Keep original _state untouched; just gate per call.
        // Future: if needed, distinguish pilot vs production — pilot always active.
        if pack.manifest.coverage.isPilot { return raw }
        return .failed("Content pack outside active lifecycle \(pack.manifest.activeFrom?.description ?? "?") .. \(pack.manifest.activeThrough?.description ?? "?")")
    }

    /// Raw load without lifecycle gating (single lock-protected initialization).
    private func loadIfNeededRaw() -> State {
        lock.lock()
        if case .notLoaded = _state {
            lock.unlock()
            let decoded = attemptLoadRaw()
            lock.lock()
            if case .notLoaded = _state {
                _state = decoded
                if case .loaded(let pack) = decoded {
                    indexes = Self.makeIndexes(for: pack)
                }
            }
            let final = _state
            lock.unlock()
            return final
        } else {
            let cur = _state
            lock.unlock()
            return cur
        }
    }

    private func attemptLoadRaw() -> State {
        if let url = bundle.url(forResource: singleFileName, withExtension: "json", subdirectory: subdirectory) {
            return decodeRaw(from: url)
        }
        if let url = bundle.url(forResource: singleFileName, withExtension: "json") {
            return decodeRaw(from: url)
        }
        if let manifestURL = bundle.url(forResource: "manifest", withExtension: "json", subdirectory: subdirectory),
           let sunURL = bundle.url(forResource: "sunRecords", withExtension: "json", subdirectory: subdirectory) {
            return decodeSplitRaw(manifestURL: manifestURL, sunURL: sunURL)
        }
        return .failed("Content pack not found in bundle subdirectory \(subdirectory)")
    }

    private func decodeRaw(from url: URL) -> State {
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let pack = try decoder.decode(CompiledContentPack.self, from: data)
            try pack.validate()
            if pack.manifest.schemaVersion != ContentPackManifest.currentSchemaVersion {
                return .failed("Unsupported schemaVersion \(pack.manifest.schemaVersion)")
            }
            return .loaded(pack)
        } catch let error as DecodingError {
            return .failed("Malformed JSON: \(error.localizedDescription)")
        } catch let error as ContentPackError {
            return .failed("Validation failed: \(error)")
        } catch {
            return .failed("Load error: \(error.localizedDescription)")
        }
    }

    private func decodeSplitRaw(manifestURL: URL, sunURL: URL) -> State {
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let manifestData = try Data(contentsOf: manifestURL)
            let manifest = try decoder.decode(ContentPackManifest.self, from: manifestData)
            let sunData = try Data(contentsOf: sunURL)
            let sunRecords = try decoder.decode([SunDayRecord].self, from: sunData)
            let moonModifiers: [MoonModifier]
            if let url = bundle.url(forResource: "moonModifiers", withExtension: "json", subdirectory: subdirectory) {
                moonModifiers = try decoder.decode([MoonModifier].self, from: Data(contentsOf: url))
            } else { moonModifiers = [] }
            let risingModifiers: [RisingModifier]
            if let url = bundle.url(forResource: "risingModifiers", withExtension: "json", subdirectory: subdirectory) {
                risingModifiers = try decoder.decode([RisingModifier].self, from: Data(contentsOf: url))
            } else { risingModifiers = [] }
            let archetypeModifiers: [ArchetypeModifier]
            if let url = bundle.url(forResource: "archetypeModifiers", withExtension: "json", subdirectory: subdirectory) {
                archetypeModifiers = try decoder.decode([ArchetypeModifier].self, from: Data(contentsOf: url))
            } else { archetypeModifiers = [] }
            let copyPools: CopyPools?
            if let url = bundle.url(forResource: "copyPools", withExtension: "json", subdirectory: subdirectory) {
                copyPools = try decoder.decode(CopyPools.self, from: Data(contentsOf: url))
            } else { copyPools = nil }
            let pack = CompiledContentPack(
                manifest: manifest,
                sunRecords: sunRecords,
                moonModifiers: moonModifiers,
                risingModifiers: risingModifiers,
                archetypeModifiers: archetypeModifiers,
                copyPools: copyPools
            )
            try pack.validate()
            return .loaded(pack)
        } catch {
            return .failed("Split load error: \(error.localizedDescription)")
        }
    }

    // MARK: - Direct decode helper (testing, no bundle)

    static func decodePack(from data: Data) throws -> CompiledContentPack {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let pack = try decoder.decode(CompiledContentPack.self, from: data)
        try pack.validate()
        guard pack.manifest.schemaVersion == ContentPackManifest.currentSchemaVersion else {
            throw ContentPackError.unsupportedSchemaVersion(pack.manifest.schemaVersion)
        }
        return pack
    }
}
