import Foundation

// MARK: - Compact helpers

private struct AnyCodingKey: CodingKey {
    var stringValue: String
    var intValue: Int?
    init(stringValue: String) { self.stringValue = stringValue; self.intValue = nil }
    init(intValue: Int) { self.stringValue = "\(intValue)"; self.intValue = intValue }
}

// Dimension order for compact array representation. Must match compiler.
private let compactDimensionOrder: [String] = MoodDimension.allCases.map { $0.rawValue } // overall, romance, social, career, energy, confidence, patience, chaos

private func dictFromCompactArray(_ arr: [Int]) -> [String: Int] {
    var dict: [String: Int] = [:]
    for (idx, key) in compactDimensionOrder.enumerated() where idx < arr.count {
        dict[key] = arr[idx]
    }
    return dict
}
private func compactArrayFromDict(_ dict: [String: Int]) -> [Int] {
    compactDimensionOrder.map { dict[$0] ?? 50 }
}

/// Central semantic theme taxonomy for deterministic composition (small, typed, compiler-validated).
enum ContentTheme: String, CaseIterable, Sendable, Hashable, Codable {
    case romance
    case career
    case social
    case confidence
    case patience
    case energy
    case chaos
    case reset
    case boundaries
    case communication
    case focus

    /// Stable sort order for deterministic selection.
    static var allRawValues: [String] { allCases.map(\.rawValue) }
}

// MARK: - Sun base record

/// AI-authored daily Sun base (one per canonical day × 12 signs).
/// Pilot: 14 keys × 12 = 168 records. Full: 366 × 12 = 4392.
struct SunDayRecord: Sendable, Hashable {
    static let headlineMaxLength = 120
    static let readingMaxLength = 600
    static let flagMaxLength = 140
    static let summaryMaxLength = 280
    static let tagMaxLength = 40

    /// Canonical key "MM-DD"
    let dayKey: String
    /// Lowercase sign rawValue, e.g. "libra"
    let sunSign: String
    /// Base scores (mode-neutral, before Moon/Rising/Archetype composition)
    let scores: [String: Int]
    /// Category tags for feed filtering (optional)
    let tags: [String]?
    let headline: String
    let personal: String
    let love: String
    let career: String
    let social: String
    let greenFlag: String
    let redFlag: String
    let summary: String?
    /// Influence weight hint for resolver (0.5...1.5), optional
    let influenceWeight: Double?

    init(
        dayKey: String,
        sunSign: String,
        scores: [String: Int],
        tags: [String]? = nil,
        headline: String,
        personal: String,
        love: String,
        career: String,
        social: String,
        greenFlag: String,
        redFlag: String,
        summary: String? = nil,
        influenceWeight: Double? = nil
    ) {
        self.dayKey = dayKey
        self.sunSign = sunSign
        self.scores = scores
        self.tags = tags
        self.headline = headline
        self.personal = personal
        self.love = love
        self.career = career
        self.social = social
        self.greenFlag = greenFlag
        self.redFlag = redFlag
        self.summary = summary
        self.influenceWeight = influenceWeight
    }

    /// Convenience typed accessor for scores.
    func moodScores() throws -> MoodScores {
        var dict: [MoodDimension: Int] = [:]
        for dim in MoodDimension.allCases {
            guard let v = scores[dim.rawValue] else {
                throw ForecastValidationError.missingDimension(dim)
            }
            guard (0...100).contains(v) else {
                throw ForecastValidationError.scoreOutOfRange(dimension: dim, value: v, metricName: dim.rawValue)
            }
            dict[dim] = v
        }
        return try MoodScores(validating: dict)
    }

    func validate() throws {
        // Validate day key parses
        _ = try CanonicalDayKey(key: dayKey)
        guard WesternZodiacSign(rawValue: sunSign) != nil else {
            throw ContentPackError.invalidReference("sunSign \(sunSign)")
        }
        // Scores
        _ = try moodScores()
        // Text lengths
        try validateText(headline, field: "headline", max: Self.headlineMaxLength)
        try validateText(personal, field: "personal", max: Self.readingMaxLength)
        try validateText(love, field: "love", max: Self.readingMaxLength)
        try validateText(career, field: "career", max: Self.readingMaxLength)
        try validateText(social, field: "social", max: Self.readingMaxLength)
        try validateText(greenFlag, field: "greenFlag", max: Self.flagMaxLength)
        try validateText(redFlag, field: "redFlag", max: Self.flagMaxLength)
        if let summary {
            try validateText(summary, field: "summary", max: Self.summaryMaxLength)
        }
        if let tags {
            for t in tags where t.count > Self.tagMaxLength {
                throw ContentPackError.invalidTextLength(field: "tags", length: t.count, max: Self.tagMaxLength)
            }
            // Validate tags against central taxonomy — pilot may have arbitrary but production must not
            // We validate strictly: any tag not in ContentTheme is invalid
            let allowed = Set(ContentTheme.allRawValues)
            for t in tags where !t.isEmpty {
                // Allow MoodDimension raw values as aliases for now, but prefer ContentTheme
                if !allowed.contains(t) && MoodDimension(rawValue: t) == nil {
                    throw ContentPackError.invalidReference("unknown tag/theme \(t)")
                }
            }
        }
        if let w = influenceWeight, !(0.3...2.0).contains(w) {
            throw ContentPackError.malformedJSON("influenceWeight \(w) out of range")
        }
    }

    private func validateText(_ text: String, field: String, max: Int) throws {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            throw ContentPackError.invalidTextLength(field: field, length: 0, max: max)
        }
        guard trimmed.count <= max else {
            throw ContentPackError.invalidTextLength(field: field, length: trimmed.count, max: max)
        }
    }
}

extension SunDayRecord: Codable {
    enum LongKeys: String, CodingKey {
        case dayKey, sunSign, scores, tags, headline, personal, love, career, social, greenFlag, redFlag, summary, influenceWeight
    }
    func encode(to encoder: any Encoder) throws {
        var c = encoder.container(keyedBy: LongKeys.self)
        try c.encode(dayKey, forKey: .dayKey)
        try c.encode(sunSign, forKey: .sunSign)
        try c.encode(scores, forKey: .scores)
        try c.encodeIfPresent(tags, forKey: .tags)
        try c.encode(headline, forKey: .headline)
        try c.encode(personal, forKey: .personal)
        try c.encode(love, forKey: .love)
        try c.encode(career, forKey: .career)
        try c.encode(social, forKey: .social)
        try c.encode(greenFlag, forKey: .greenFlag)
        try c.encode(redFlag, forKey: .redFlag)
        try c.encodeIfPresent(summary, forKey: .summary)
        try c.encodeIfPresent(influenceWeight, forKey: .influenceWeight)
    }
    init(from decoder: any Decoder) throws {
        let c = try decoder.container(keyedBy: AnyCodingKey.self)
        func str(_ long: String, _ short: String) throws -> String {
            if let v = try? c.decode(String.self, forKey: AnyCodingKey(stringValue: long)) { return v }
            if let v = try? c.decode(String.self, forKey: AnyCodingKey(stringValue: short)) { return v }
            throw DecodingError.keyNotFound(AnyCodingKey(stringValue: long), .init(codingPath: decoder.codingPath, debugDescription: "Missing \(long)/\(short)"))
        }
        func optStr(_ long: String, _ short: String) -> String? {
            (try? c.decode(String.self, forKey: AnyCodingKey(stringValue: long))) ?? (try? c.decode(String.self, forKey: AnyCodingKey(stringValue: short)))
        }
        func optDouble(_ long: String, _ short: String) -> Double? {
            (try? c.decode(Double.self, forKey: AnyCodingKey(stringValue: long))) ?? (try? c.decode(Double.self, forKey: AnyCodingKey(stringValue: short)))
        }
        self.dayKey = try str("dayKey", "k")
        self.sunSign = try str("sunSign", "s")
        // scores: dict or array
        if let dict = try? c.decode([String: Int].self, forKey: AnyCodingKey(stringValue: "scores")) {
            self.scores = dict
        } else if let arr = try? c.decode([Int].self, forKey: AnyCodingKey(stringValue: "sc")) {
            self.scores = dictFromCompactArray(arr)
        } else if let arr = try? c.decode([Int].self, forKey: AnyCodingKey(stringValue: "scores")) {
            self.scores = dictFromCompactArray(arr)
        } else {
            throw DecodingError.keyNotFound(AnyCodingKey(stringValue: "scores"), .init(codingPath: decoder.codingPath, debugDescription: "Missing scores/sc"))
        }
        self.tags = (try? c.decode([String].self, forKey: AnyCodingKey(stringValue: "tags"))) ?? (try? c.decode([String].self, forKey: AnyCodingKey(stringValue: "t")))
        self.headline = try str("headline", "h")
        self.personal = try str("personal", "p")
        self.love = try str("love", "l")
        self.career = try str("career", "c")
        // social vs "so"
        if let v = try? c.decode(String.self, forKey: AnyCodingKey(stringValue: "social")) { self.social = v }
        else { self.social = try c.decode(String.self, forKey: AnyCodingKey(stringValue: "so")) }
        if let v = try? c.decode(String.self, forKey: AnyCodingKey(stringValue: "greenFlag")) { self.greenFlag = v }
        else { self.greenFlag = try c.decode(String.self, forKey: AnyCodingKey(stringValue: "g")) }
        if let v = try? c.decode(String.self, forKey: AnyCodingKey(stringValue: "redFlag")) { self.redFlag = v }
        else { self.redFlag = try c.decode(String.self, forKey: AnyCodingKey(stringValue: "r")) }
        self.summary = optStr("summary", "su")
        self.influenceWeight = optDouble("influenceWeight", "w")
    }
}

// MARK: - Modifier records

/// Moon modifier — one per sign, applied as delta to Sun base.
/// I.1: thematic fragment pools for variation (fragments[theme] -> [String]).
struct MoonModifier: Sendable, Hashable {
    static let deltaBound = 14
    static let fragmentMaxLength = 180

    let moonSign: String
    /// Deltas per dimension (bounded small, e.g. -12...+12)
    let deltas: [String: Int]
    let emotionalFragment: String?
    /// Theme-aware pools: romance, career, social, confidence, patience, energy, chaos, reset, boundaries, communication, focus
    let fragments: [String: [String]]?
    let affinityTags: [String]?

    init(moonSign: String, deltas: [String: Int], emotionalFragment: String? = nil, fragments: [String: [String]]? = nil, affinityTags: [String]? = nil) {
        self.moonSign = moonSign
        self.deltas = deltas
        self.emotionalFragment = emotionalFragment
        self.fragments = fragments
        self.affinityTags = affinityTags
    }

    func validate() throws {
        guard WesternZodiacSign(rawValue: moonSign) != nil else {
            throw ContentPackError.invalidReference("moonSign \(moonSign)")
        }
        for (k, v) in deltas {
            guard MoodDimension(rawValue: k) != nil else {
                throw ContentPackError.invalidReference("delta dimension \(k)")
            }
            guard (-Self.deltaBound...Self.deltaBound).contains(v) else {
                throw ContentPackError.invalidScore(dimension: k, value: v)
            }
        }
        if let frag = emotionalFragment {
            guard !frag.trimmingCharacters(in: .whitespaces).isEmpty else {
                throw ContentPackError.invalidTextLength(field: "moonFragment", length: 0, max: Self.fragmentMaxLength)
            }
            guard frag.count <= Self.fragmentMaxLength else {
                throw ContentPackError.invalidTextLength(field: "moonFragment", length: frag.count, max: Self.fragmentMaxLength)
            }
        }
        if let fr = fragments {
            for (theme, arr) in fr {
                guard ContentTheme(rawValue: theme) != nil || MoodDimension(rawValue: theme) != nil else {
                    throw ContentPackError.invalidReference("moon fragments unknown theme \(theme)")
                }
                for s in arr {
                    guard !s.trimmingCharacters(in: .whitespaces).isEmpty else {
                        throw ContentPackError.invalidTextLength(field: "moonFragment.\(theme)", length: 0, max: Self.fragmentMaxLength)
                    }
                    guard s.count <= Self.fragmentMaxLength else {
                        throw ContentPackError.invalidTextLength(field: "moonFragment.\(theme)", length: s.count, max: Self.fragmentMaxLength)
                    }
                }
            }
        }
    }

    /// Deterministic fragment selection for a day — theme-aware, stable.
    /// Fallback: requested theme → generic emotionalFragment → nil. Never uses unrelated theme's copy.
    func fragment(for theme: String?, stableSeed: UInt64) -> String? {
        if let theme, let pools = fragments?[theme], !pools.isEmpty {
            let idx = Int(stableSeed % UInt64(pools.count))
            return pools[idx]
        }
        // Semantically sensible fallback: base fragment, not unrelated theme pool
        return emotionalFragment
    }
}
extension MoonModifier: Codable {
    enum LongKeys: String, CodingKey { case moonSign, deltas, emotionalFragment, fragments, affinityTags }
    func encode(to encoder: any Encoder) throws {
        var c = encoder.container(keyedBy: LongKeys.self)
        try c.encode(moonSign, forKey: .moonSign)
        try c.encode(deltas, forKey: .deltas)
        try c.encodeIfPresent(emotionalFragment, forKey: .emotionalFragment)
        try c.encodeIfPresent(fragments, forKey: .fragments)
        try c.encodeIfPresent(affinityTags, forKey: .affinityTags)
    }
    init(from decoder: any Decoder) throws {
        let c = try decoder.container(keyedBy: AnyCodingKey.self)
        if let v = try? c.decode(String.self, forKey: AnyCodingKey(stringValue: "moonSign")) { moonSign = v }
        else { moonSign = try c.decode(String.self, forKey: AnyCodingKey(stringValue: "m")) }
        if let dict = try? c.decode([String:Int].self, forKey: AnyCodingKey(stringValue: "deltas")) { deltas = dict }
        else if let arr = try? c.decode([Int].self, forKey: AnyCodingKey(stringValue: "d")) { deltas = dictFromCompactArray(arr) }
        else if let arr = try? c.decode([Int].self, forKey: AnyCodingKey(stringValue: "deltas")) { deltas = dictFromCompactArray(arr) }
        else { deltas = [:] }
        emotionalFragment = (try? c.decode(String.self, forKey: AnyCodingKey(stringValue: "emotionalFragment"))) ?? (try? c.decode(String.self, forKey: AnyCodingKey(stringValue: "f")))
        fragments = (try? c.decode([String: [String]].self, forKey: AnyCodingKey(stringValue: "fragments"))) ?? (try? c.decode([String: [String]].self, forKey: AnyCodingKey(stringValue: "fr")))
        affinityTags = (try? c.decode([String].self, forKey: AnyCodingKey(stringValue: "affinityTags"))) ?? (try? c.decode([String].self, forKey: AnyCodingKey(stringValue: "at")))
    }
}

/// Rising modifier — one per sign. I.1 thematic fragments.
struct RisingModifier: Sendable, Hashable {
    static let deltaBound = 12
    static let fragmentMaxLength = 180

    let risingSign: String
    let deltas: [String: Int]
    let outwardFragment: String?
    let fragments: [String: [String]]?
    let affinityTags: [String]?

    init(risingSign: String, deltas: [String:Int], outwardFragment: String? = nil, fragments: [String: [String]]? = nil, affinityTags: [String]? = nil) {
        self.risingSign = risingSign
        self.deltas = deltas
        self.outwardFragment = outwardFragment
        self.fragments = fragments
        self.affinityTags = affinityTags
    }

    func validate() throws {
        guard WesternZodiacSign(rawValue: risingSign) != nil else {
            throw ContentPackError.invalidReference("risingSign \(risingSign)")
        }
        for (k, v) in deltas {
            guard MoodDimension(rawValue: k) != nil else {
                throw ContentPackError.invalidReference("delta dimension \(k)")
            }
            guard (-Self.deltaBound...Self.deltaBound).contains(v) else {
                throw ContentPackError.invalidScore(dimension: k, value: v)
            }
        }
        if let frag = outwardFragment {
            guard frag.count <= Self.fragmentMaxLength else {
                throw ContentPackError.invalidTextLength(field: "risingFragment", length: frag.count, max: Self.fragmentMaxLength)
            }
        }
        if let fr = fragments {
            for (theme, arr) in fr {
                guard ContentTheme(rawValue: theme) != nil || MoodDimension(rawValue: theme) != nil else {
                    throw ContentPackError.invalidReference("rising fragments unknown theme \(theme)")
                }
                for s in arr where s.count > Self.fragmentMaxLength {
                    throw ContentPackError.invalidTextLength(field: "risingFragment.\(theme)", length: s.count, max: Self.fragmentMaxLength)
                }
            }
        }
    }

    func fragment(for theme: String?, stableSeed: UInt64) -> String? {
        if let theme, let pools = fragments?[theme], !pools.isEmpty {
            return pools[Int(stableSeed % UInt64(pools.count))]
        }
        return outwardFragment
    }

    /// Non-theme fallback accessor for coverage validation
    var fragmentPoolCoverage: (themeCount: Int, minVariants: Int, maxVariants: Int) {
        guard let fr = fragments else { return (0,0,0) }
        let counts = fr.values.map(\.count)
        return (fr.count, counts.min() ?? 0, counts.max() ?? 0)
    }
}
extension RisingModifier: Codable {
    func encode(to encoder: any Encoder) throws {
        var c = encoder.container(keyedBy: AnyCodingKey.self)
        try c.encode(risingSign, forKey: AnyCodingKey(stringValue: "risingSign"))
        try c.encode(deltas, forKey: AnyCodingKey(stringValue: "deltas"))
        try c.encodeIfPresent(outwardFragment, forKey: AnyCodingKey(stringValue: "outwardFragment"))
        try c.encodeIfPresent(fragments, forKey: AnyCodingKey(stringValue: "fragments"))
        try c.encodeIfPresent(affinityTags, forKey: AnyCodingKey(stringValue: "affinityTags"))
    }
    init(from decoder: any Decoder) throws {
        let c = try decoder.container(keyedBy: AnyCodingKey.self)
        if let v = try? c.decode(String.self, forKey: AnyCodingKey(stringValue: "risingSign")) { risingSign = v }
        else if let v = try? c.decode(String.self, forKey: AnyCodingKey(stringValue: "rs")) { risingSign = v }
        else { risingSign = try c.decode(String.self, forKey: AnyCodingKey(stringValue: "r")) }
        if let dict = try? c.decode([String:Int].self, forKey: AnyCodingKey(stringValue: "deltas")) { deltas = dict }
        else if let arr = try? c.decode([Int].self, forKey: AnyCodingKey(stringValue: "d")) { deltas = dictFromCompactArray(arr) }
        else { deltas = [:] }
        outwardFragment = (try? c.decode(String.self, forKey: AnyCodingKey(stringValue: "outwardFragment"))) ?? (try? c.decode(String.self, forKey: AnyCodingKey(stringValue: "f")))
        fragments = (try? c.decode([String: [String]].self, forKey: AnyCodingKey(stringValue: "fragments"))) ?? (try? c.decode([String: [String]].self, forKey: AnyCodingKey(stringValue: "fr")))
        affinityTags = (try? c.decode([String].self, forKey: AnyCodingKey(stringValue: "affinityTags"))) ?? (try? c.decode([String].self, forKey: AnyCodingKey(stringValue: "at")))
    }
}

/// Humay archetype modifier — one per archetype id (12 total). I.1 adds thematic rotation.
struct ArchetypeModifier: Sendable, Hashable {
    static let deltaBound = 10
    static let fragmentMaxLength = 160

    let archetypeID: String
    let deltas: [String: Int]
    let fragment: String?
    let fragments: [String: [String]]?
    let preferredTags: [String]?

    init(archetypeID: String, deltas: [String:Int], fragment: String? = nil, fragments: [String: [String]]? = nil, preferredTags: [String]? = nil) {
        self.archetypeID = archetypeID
        self.deltas = deltas
        self.fragment = fragment
        self.fragments = fragments
        self.preferredTags = preferredTags
    }

    func validate() throws {
        guard HumayArchetype.catalog.contains(where: { $0.id == archetypeID }) else {
            throw ContentPackError.invalidReference("archetypeID \(archetypeID)")
        }
        for (k, v) in deltas {
            guard MoodDimension(rawValue: k) != nil else {
                throw ContentPackError.invalidReference("delta dimension \(k)")
            }
            guard (-Self.deltaBound...Self.deltaBound).contains(v) else {
                throw ContentPackError.invalidScore(dimension: k, value: v)
            }
        }
        if let frag = fragment {
            guard frag.count <= Self.fragmentMaxLength else {
                throw ContentPackError.invalidTextLength(field: "archetypeFragment", length: frag.count, max: Self.fragmentMaxLength)
            }
        }
        if let fr = fragments {
            for (theme, arr) in fr {
                guard ContentTheme(rawValue: theme) != nil || MoodDimension(rawValue: theme) != nil else {
                    throw ContentPackError.invalidReference("archetype fragments unknown theme \(theme)")
                }
                for s in arr where s.count > Self.fragmentMaxLength {
                    throw ContentPackError.invalidTextLength(field: "archetypeFragment.\(theme)", length: s.count, max: Self.fragmentMaxLength)
                }
            }
        }
    }

    func fragment(for theme: String?, stableSeed: UInt64) -> String? {
        if let theme, let pools = fragments?[theme], !pools.isEmpty {
            return pools[Int(stableSeed % UInt64(pools.count))]
        }
        return fragment
    }
}
extension ArchetypeModifier: Codable {
    func encode(to encoder: any Encoder) throws {
        var c = encoder.container(keyedBy: AnyCodingKey.self)
        try c.encode(archetypeID, forKey: AnyCodingKey(stringValue: "archetypeID"))
        try c.encode(deltas, forKey: AnyCodingKey(stringValue: "deltas"))
        try c.encodeIfPresent(fragment, forKey: AnyCodingKey(stringValue: "fragment"))
        try c.encodeIfPresent(fragments, forKey: AnyCodingKey(stringValue: "fragments"))
        try c.encodeIfPresent(preferredTags, forKey: AnyCodingKey(stringValue: "preferredTags"))
    }
    init(from decoder: any Decoder) throws {
        let c = try decoder.container(keyedBy: AnyCodingKey.self)
        if let v = try? c.decode(String.self, forKey: AnyCodingKey(stringValue: "archetypeID")) { archetypeID = v }
        else { archetypeID = try c.decode(String.self, forKey: AnyCodingKey(stringValue: "a")) }
        if let dict = try? c.decode([String:Int].self, forKey: AnyCodingKey(stringValue: "deltas")) { deltas = dict }
        else if let arr = try? c.decode([Int].self, forKey: AnyCodingKey(stringValue: "d")) { deltas = dictFromCompactArray(arr) }
        else { deltas = [:] }
        fragment = (try? c.decode(String.self, forKey: AnyCodingKey(stringValue: "fragment"))) ?? (try? c.decode(String.self, forKey: AnyCodingKey(stringValue: "f")))
        fragments = (try? c.decode([String: [String]].self, forKey: AnyCodingKey(stringValue: "fragments"))) ?? (try? c.decode([String: [String]].self, forKey: AnyCodingKey(stringValue: "fr")))
        preferredTags = (try? c.decode([String].self, forKey: AnyCodingKey(stringValue: "preferredTags"))) ?? (try? c.decode([String].self, forKey: AnyCodingKey(stringValue: "pt")))
    }
}

// MARK: - Copy pools

/// Reusable text pools for expression and fallback copy.
/// Stored once; Sun records do not reference these by index in source,
/// but the compiled representation may intern flags via pools.
struct CopyPools: Sendable, Hashable, Codable {
    /// Green/red flag pools (optional intern targets)
    var greenFlags: [String]?
    var redFlags: [String]?
    /// Mode-specific roast lines (title + body pairs flattened)
    var roastByMode: [String: [String]]?
    var revealSecrets: [String]?
    var revealFollowUps: [String]?
    var genericHeadlines: [String]?

    func validate() throws {
        if let flags = greenFlags {
            for f in flags where f.count > SunDayRecord.flagMaxLength {
                throw ContentPackError.invalidTextLength(field: "copyPools.greenFlags", length: f.count, max: SunDayRecord.flagMaxLength)
            }
        }
        if let flags = redFlags {
            for f in flags where f.count > SunDayRecord.flagMaxLength {
                throw ContentPackError.invalidTextLength(field: "copyPools.redFlags", length: f.count, max: SunDayRecord.flagMaxLength)
            }
        }
    }
}

// MARK: - Compiled bundle (single file when convenient)

/// Top-level compiled content pack as decoded at runtime.
/// File layout may be one JSON file or split files merged by the repository;
/// this type represents the merged in-memory model.
struct CompiledContentPack: Sendable, Hashable, Codable {
    let manifest: ContentPackManifest
    let sunRecords: [SunDayRecord]
    let moonModifiers: [MoonModifier]
    let risingModifiers: [RisingModifier]
    let archetypeModifiers: [ArchetypeModifier]
    let copyPools: CopyPools?

    func validate() throws {
        try manifest.validate()
        // Unique check: dayKey + sunSign + validate individual records
        var seen = Set<String>()
        var keysSeen = Set<String>()
        var signCountByKey: [String: Set<String>] = [:]
        for r in sunRecords {
            try r.validate()
            let key = "\(r.dayKey)|\(r.sunSign)"
            guard !seen.contains(key) else {
                throw ContentPackError.duplicateRecord(key)
            }
            seen.insert(key)
            keysSeen.insert(r.dayKey)
            signCountByKey[r.dayKey, default: []].insert(r.sunSign)
            // Validate canonical day key parsing
            _ = try CanonicalDayKey(key: r.dayKey)
        }
        // Extra date validation: no unexpected extra dates beyond canonical calendar
        for k in keysSeen {
            _ = try CanonicalDayKey(key: k)
        }
        // Modifier uniqueness & validation
        let moonSigns = moonModifiers.map(\.moonSign)
        guard Set(moonSigns).count == moonSigns.count else {
            throw ContentPackError.duplicateRecord("moonModifier")
        }
        for m in moonModifiers { try m.validate() }

        let risingSigns = risingModifiers.map(\.risingSign)
        guard Set(risingSigns).count == risingSigns.count else {
            throw ContentPackError.duplicateRecord("risingModifier")
        }
        for m in risingModifiers { try m.validate() }

        let archIDs = archetypeModifiers.map(\.archetypeID)
        guard Set(archIDs).count == archIDs.count else {
            throw ContentPackError.duplicateRecord("archetypeModifier")
        }
        for m in archetypeModifiers { try m.validate() }

        try copyPools?.validate()

        // Coverage manifest vs actual must agree (do not trust manifest blindly)
        if manifest.coverage.sunRecordCount != sunRecords.count {
            throw ContentPackError.malformedJSON("manifest.coverage.sunRecordCount \(manifest.coverage.sunRecordCount) != actual \(sunRecords.count)")
        }
        if manifest.coverage.dayKeyCount != keysSeen.count {
            throw ContentPackError.malformedJSON("manifest.coverage.dayKeyCount \(manifest.coverage.dayKeyCount) != actual \(keysSeen.count)")
        }

        // Production completeness contract
        if !manifest.coverage.isPilot {
            // Must have exactly 366 canonical keys including leap day
            let allKeys = Set(CanonicalDayKey.all366.map(\.key))
            if keysSeen != allKeys {
                let missing = allKeys.subtracting(keysSeen)
                let extra = keysSeen.subtracting(allKeys)
                if !missing.isEmpty {
                    throw ContentPackError.missingRecord("production missing dayKeys \(missing.sorted().prefix(5))")
                }
                if !extra.isEmpty {
                    throw ContentPackError.duplicateRecord("unexpected extra date \(extra)")
                }
            }
            if sunRecords.count != 366 * 12 {
                throw ContentPackError.malformedJSON("production sunRecordCount must be 4392, got \(sunRecords.count)")
            }
            // Every key must have exactly 12 signs
            for k in allKeys {
                let signs = signCountByKey[k] ?? []
                if signs.count != 12 {
                    throw ContentPackError.missingRecord("production key \(k) missing signs: \(signs)")
                }
            }
            // Modifier completeness
            if moonModifiers.count != 12 {
                throw ContentPackError.missingRecord("production requires 12 Moon modifiers, got \(moonModifiers.count)")
            }
            if risingModifiers.count != 12 {
                throw ContentPackError.missingRecord("production requires 12 Rising modifiers, got \(risingModifiers.count)")
            }
            if archetypeModifiers.count != 12 {
                throw ContentPackError.missingRecord("production requires 12 archetype modifiers, got \(archetypeModifiers.count)")
            }
            if !manifest.coverage.includesLeapDay {
                throw ContentPackError.malformedJSON("production must include 02-29")
            }
        } else {
            // Pilot: dayKeyCount / sunRecordCount already validated above; isPilot flag honest
            // No extra enforcement beyond per-record checks.
        }
    }
}
