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

    // Cached decode, protected by lock for Sendable compliance.
    private let lock = NSLock()
    private var _state: State = .notLoaded
    // Immutable indexes built once after decode (O(1) lookups for 4392 records)
    private var sunIndex: [String: SunDayRecord] = [:]
    private var moonIndex: [String: MoonModifier] = [:]
    private var risingIndex: [String: RisingModifier] = [:]
    private var archetypeIndex: [String: ArchetypeModifier] = [:]
    private var indexesBuilt = false

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
        buildIndexes(for: pack)
    }

    private func buildIndexes(for pack: CompiledContentPack) {
        var s: [String: SunDayRecord] = [:]
        s.reserveCapacity(pack.sunRecords.count)
        for r in pack.sunRecords {
            s["\(r.dayKey)|\(r.sunSign)"] = r
        }
        sunIndex = s
        moonIndex = Dictionary(uniqueKeysWithValues: pack.moonModifiers.map { ($0.moonSign, $0) })
        risingIndex = Dictionary(uniqueKeysWithValues: pack.risingModifiers.map { ($0.risingSign, $0) })
        archetypeIndex = Dictionary(uniqueKeysWithValues: pack.archetypeModifiers.map { ($0.archetypeID, $0) })
        indexesBuilt = true
    }

    private func ensureIndexesIfNeeded(for pack: CompiledContentPack) {
        if !indexesBuilt {
            buildIndexes(for: pack)
        }
    }

    // MARK: - Public accessors (cached)

    var manifest: ContentPackManifest? {
        switch loadIfNeeded() {
        case .loaded(let pack): pack.manifest
        case .failed, .notLoaded: nil
        }
    }

    var isAvailable: Bool {
        if case .loaded = loadIfNeeded() { return true }
        return false
    }

    var loadError: String? {
        if case .failed(let msg) = loadIfNeeded() { return msg }
        return nil
    }

    var pack: CompiledContentPack? {
        if case .loaded(let p) = loadIfNeeded() { return p }
        return nil
    }

    func sunRecord(dayKey: CanonicalDayKey, sunSign: WesternZodiacSign) -> SunDayRecord? {
        guard case .loaded(let pack) = loadIfNeeded() else { return nil }
        ensureIndexesIfNeeded(for: pack)
        return sunIndex["\(dayKey.key)|\(sunSign.rawValue)"]
    }

    func moonModifier(sign: WesternZodiacSign) -> MoonModifier? {
        guard case .loaded(let pack) = loadIfNeeded() else { return nil }
        ensureIndexesIfNeeded(for: pack)
        return moonIndex[sign.rawValue]
    }

    func risingModifier(sign: WesternZodiacSign) -> RisingModifier? {
        guard case .loaded(let pack) = loadIfNeeded() else { return nil }
        ensureIndexesIfNeeded(for: pack)
        return risingIndex[sign.rawValue]
    }

    func archetypeModifier(id: String) -> ArchetypeModifier? {
        guard case .loaded(let pack) = loadIfNeeded() else { return nil }
        ensureIndexesIfNeeded(for: pack)
        return archetypeIndex[id]
    }

    var copyPools: CopyPools? {
        guard case .loaded(let pack) = loadIfNeeded() else { return nil }
        return pack.copyPools
    }

    /// Force reload (testing).
    func reload() {
        lock.lock()
        _state = .notLoaded
        sunIndex = [:]
        moonIndex = [:]
        risingIndex = [:]
        archetypeIndex = [:]
        indexesBuilt = false
        lock.unlock()
        _ = loadIfNeeded()
    }

    // MARK: - Loading

    private func loadIfNeeded() -> State {
        lock.lock()
        let current = _state
        lock.unlock()
        if case .notLoaded = current {
            let loaded = attemptLoad()
            lock.lock()
            _state = loaded
            lock.unlock()
            return loaded
        }
        return current
    }

    private func attemptLoad() -> State {
        // 1) Try single-file bundle resource: ContentPacks/v1/contentPack.json
        if let url = bundle.url(forResource: singleFileName, withExtension: "json", subdirectory: subdirectory) {
            return decode(from: url)
        }
        // Fallback: try without subdirectory (flat Resources)
        if let url = bundle.url(forResource: singleFileName, withExtension: "json") {
            return decode(from: url)
        }
        // 2) Try split files manifest + sunRecords etc.
        if let manifestURL = bundle.url(forResource: "manifest", withExtension: "json", subdirectory: subdirectory),
           let sunURL = bundle.url(forResource: "sunRecords", withExtension: "json", subdirectory: subdirectory) {
            return decodeSplit(manifestURL: manifestURL, sunURL: sunURL)
        }
        return .failed("Content pack not found in bundle subdirectory \(subdirectory)")
    }

    private func decode(from url: URL) -> State {
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let pack = try decoder.decode(CompiledContentPack.self, from: data)
            try pack.validate()
            if pack.manifest.schemaVersion != ContentPackManifest.currentSchemaVersion {
                return .failed("Unsupported schemaVersion \(pack.manifest.schemaVersion)")
            }
            lock.lock()
            buildIndexes(for: pack)
            lock.unlock()
            return .loaded(pack)
        } catch let error as DecodingError {
            return .failed("Malformed JSON: \(error.localizedDescription)")
        } catch let error as ContentPackError {
            return .failed("Validation failed: \(error)")
        } catch {
            return .failed("Load error: \(error.localizedDescription)")
        }
    }

    private func decodeSplit(manifestURL: URL, sunURL: URL) -> State {
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let manifestData = try Data(contentsOf: manifestURL)
            let manifest = try decoder.decode(ContentPackManifest.self, from: manifestData)
            let sunData = try Data(contentsOf: sunURL)
            let sunRecords = try decoder.decode([SunDayRecord].self, from: sunData)

            // Optional modifiers
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
            lock.lock()
            buildIndexes(for: pack)
            lock.unlock()
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
