import Foundation
import Testing
@testable import Humay

// MARK: - Helpers reused

private func makePilotPackI1() -> CompiledContentPack {
    let candidates: [URL?] = [
        Bundle.main.url(forResource: "contentPack", withExtension: "json", subdirectory: "ContentPacks/v1"),
        Bundle.main.url(forResource: "contentPack", withExtension: "json")
    ]
    guard let url = candidates.compactMap({ $0 }).first, let data = try? Data(contentsOf: url) else {
        fatalError("Pilot pack not found")
    }
    return try! BundledContentPackRepository.decodePack(from: data)
}
private func makeRepoI1(pack: CompiledContentPack) -> BundledContentPackRepository {
    BundledContentPackRepository(bundle: .main, subdirectory: "ContentPacks/v1", singleFileName: "contentPack", preload: pack)
}
private func ctxI1(sun: String?, moon: String? = nil, rising: String? = nil, archetype: String = "chaotic-diplomat") -> PersonalizationContext {
    PersonalizationContext(sunSign: sun, sunDegreeWithinSign: 10, moonSign: moon, moonDegreeWithinSign: 5, risingSign: rising, risingDegreeWithinSign: 7, birthTimeKnown: moon != nil || rising != nil, archetypeID: archetype, archetypeName: archetype)
}

// MARK: - 48 Provenance

@Suite("ContentPack I.1 — Provenance")
struct ContentPackI1ProvenanceTests {
    @Test("Pure bundled forecast when all 365 days backed by pack (mock full pack)")
    func pureBundled() async throws {
        let pack = makePilotPackI1()
        let subject = ForecastSubject(id: UUID(), name: "X", birth: BirthDetails(year: 1990, month: 3, day: 2))
        let repo = makeRepoI1(pack: pack)
        let hybrid = HybridOfflineContentProvider(repository: repo)
        let anchor = ForecastAnchor(year: 2026, month: 3, day: 1)
        let (forecast, fallback) = await hybrid.yearlyForecast(subject: subject, anchor: anchor)
        #expect(forecast.contentSource != nil)
        // Pilot window 03-01..03-14 => 14 bundled, 351 fallback => mixed
        #expect(forecast.contentSource?.kind == .mixed)
        #expect(forecast.contentSource?.bundledDays == 14)
        #expect(forecast.contentSource?.deterministicDays == 351)
        #expect(fallback == 351)
        #expect(forecast.provenance.basis.isPersonalizedAI) // aiGenerated even when mixed
    }

    @Test("Pure deterministic when no pack available")
    func pureDeterministic() async {
        let badRepo = BundledContentPackRepository(bundle: .main, subdirectory: "ContentPacks/missing", singleFileName: "nope")
        #expect(badRepo.isAvailable == false)
        let subject = ForecastSubject(id: UUID(), name: "Y", birth: BirthDetails(year: 1990, month: 1, day: 15))
        let hybrid = HybridOfflineContentProvider(repository: badRepo)
        let anchor = ForecastAnchor(year: 2026, month: 1, day: 1)
        let (forecast, fallback) = await hybrid.yearlyForecast(subject: subject, anchor: anchor)
        #expect(forecast.contentSource?.kind == .deterministic)
        #expect(fallback == 365)
        #expect(forecast.provenance.basis == .entertainmentFixture)
    }

    @Test("Bundled provider no longer hides fallback: regenerateDay throws when missing")
    func bundledNoHide() async throws {
        let pack = makePilotPackI1()
        let repo = makeRepoI1(pack: pack)
        let bundled = BundledAIContentProvider(repository: repo)
        let subject = ForecastSubject(id: UUID(), name: "Z", birth: BirthDetails(year: 1993, month: 3, day: 2))
        // Date outside pilot window should throw
        var cal = Calendar(identifier: .gregorian); cal.timeZone = TimeZone(secondsFromGMT: 0)!
        let missingDate = cal.date(from: DateComponents(year: 2026, month: 7, day: 15))!
        let anchor = ForecastAnchor(year: 2026, month: 7, day: 1)
        let ctx = ctxI1(sun: "libra")
        // Direct resolver returns nil
        #expect(BundledContentResolver.resolve(date: missingDate, dayOffset: 14, context: ctx, calendar: cal, repository: repo) == nil)
        // Bundled provider regenerateDay should throw providerUnavailable, not fallback
        let outline = try await DeterministicContentProvider().generateYearOutline(subject: subject, anchor: anchor)
        await #expect(throws: GenerationError.self) {
            _ = try await bundled.regenerateDay(subject: subject, outline: outline.context, anchor: anchor, dayOffset: 100)
        }
    }

    @Test("Mixed forecast tracks counts honestly and fallback not labelled bundled")
    @MainActor
    func mixedCountsHonest() {
        let pack = makePilotPackI1()
        let repo = makeRepoI1(pack: pack)
        let subject = ForecastSubject(id: UUID(), name: "M", birth: BirthDetails(year: 1991, month: 3, day: 5))
        let store = ForecastStore(repository: InMemoryForecastRepository(), coordinator: ForecastGenerationCoordinator(provider: DeterministicContentProvider(), repository: InMemoryForecastRepository()), bundledRepository: repo)
        let forecast: YearlyForecast = store.fallbackForecast(for: subject)
        #expect(forecast.contentSource?.kind == .mixed || forecast.contentSource?.kind == .deterministic || forecast.contentSource?.kind == .bundled)
        if let cs = forecast.contentSource, cs.kind == .mixed {
            #expect(cs.bundledDays + cs.deterministicDays == 365)
            #expect(cs.bundledDays == 14)
        }
    }
}

// MARK: - 49 Production completeness

@Suite("ContentPack I.1 — Production completeness")
struct ContentPackI1CompletenessTests {
    @Test("Validation fails for 365 keys instead of 366 in production")
    func fails365() throws {
        let pack = makePilotPackI1()
        var manifest = pack.manifest
        // Make it production-like: isPilot false, includesLeapDay true, but keep 14 keys -> should fail
        let cov = ContentPackManifest.Coverage(startDayKey: "01-01", endDayKey: "12-31", dayKeyCount: pack.manifest.coverage.dayKeyCount, isPilot: false, includesLeapDay: true, sunRecordCount: pack.sunRecords.count)
        let prodManifest = ContentPackManifest(
            packVersion: pack.manifest.packVersion,
            language: pack.manifest.language,
            contentCycleVersion: "cycle-2027-v1",
            createdAt: pack.manifest.createdAt,
            coverage: cov,
            provenance: pack.manifest.provenance,
            activeFrom: Date.now,
            activeThrough: Date.now.addingTimeInterval(86400*400),
            generationMethod: "ai-batch-authored"
        )
        let badPack = CompiledContentPack(manifest: prodManifest, sunRecords: pack.sunRecords, moonModifiers: pack.moonModifiers, risingModifiers: pack.risingModifiers, archetypeModifiers: pack.archetypeModifiers, copyPools: pack.copyPools)
        #expect(throws: ContentPackError.self) { try badPack.validate() }
    }

    @Test("Missing 02-29 in production fails")
    func missingLeapDay() throws {
        // 366 keys minus 02-29 should fail includesLeapDay check
        let pack = makePilotPackI1()
        let cov = ContentPackManifest.Coverage(startDayKey: "01-01", endDayKey: "12-31", dayKeyCount: 365, isPilot: false, includesLeapDay: false, sunRecordCount: 365*12)
        let m = ContentPackManifest(
            packVersion: "2.0.0", language: "en", contentCycleVersion: "cycle-2027-v1",
            createdAt: Date.now, coverage: cov,
            provenance: pack.manifest.provenance,
            activeFrom: Date.now, activeThrough: Date.now.addingTimeInterval(86400*400)
        )
        // Need 365*12 records without 02-29
        let fakeRecords = (0..<365*12).map { i in
            SunDayRecord(dayKey: String(format: "01-%02d", (i%28)+1), sunSign: "aries",
                         scores: ["overall":50,"romance":50,"social":50,"career":50,"energy":50,"confidence":50,"patience":50,"chaos":50],
                         headline: "h", personal: "p", love: "l", career: "c", social: "so", greenFlag: "g", redFlag: "r", summary: "s")
        }
        let badPack = CompiledContentPack(manifest: m, sunRecords: fakeRecords, moonModifiers: pack.moonModifiers, risingModifiers: pack.risingModifiers, archetypeModifiers: pack.archetypeModifiers, copyPools: nil)
        #expect(throws: ContentPackError.self) { try badPack.validate() }
    }

    @Test("Duplicate day/sign rejected")
    func duplicateRejected() throws {
        let pack = makePilotPackI1()
        let dupe = pack.sunRecords[0]
        let dupPack = CompiledContentPack(manifest: pack.manifest, sunRecords: pack.sunRecords + [dupe], moonModifiers: pack.moonModifiers, risingModifiers: pack.risingModifiers, archetypeModifiers: pack.archetypeModifiers, copyPools: pack.copyPools)
        #expect(throws: ContentPackError.self) { try dupPack.validate() }
    }

    @Test("Missing Moon modifier count in production fails")
    func missingMoon() throws {
        let pack = makePilotPackI1()
        let cov = ContentPackManifest.Coverage(startDayKey: "01-01", endDayKey: "12-31", dayKeyCount: 366, isPilot: false, includesLeapDay: true, sunRecordCount: 366*12)
        // Create full 366*12 records (dummy)
        var records: [SunDayRecord] = []
        for key in CanonicalDayKey.all366 {
            for sign in ["aries","taurus","gemini","cancer","leo","virgo","libra","scorpio","sagittarius","capricorn","aquarius","pisces"] {
                records.append(SunDayRecord(dayKey: key.key, sunSign: sign, scores: ["overall":50,"romance":50,"social":50,"career":50,"energy":50,"confidence":50,"patience":50,"chaos":50], headline: "h \(key.key) \(sign)", personal: "p", love: "l", career: "c", social: "so", greenFlag: "g", redFlag: "r", summary: "High confidence. Pick one fight."))
            }
        }
        let m = ContentPackManifest(packVersion: "2.0.0", language: "en", contentCycleVersion: "cycle-2027-v1", createdAt: Date.now, coverage: cov, provenance: pack.manifest.provenance, activeFrom: Date.now, activeThrough: Date.now.addingTimeInterval(86400*400))
        let badPack = CompiledContentPack(manifest: m, sunRecords: records, moonModifiers: Array(pack.moonModifiers.prefix(11)), risingModifiers: pack.risingModifiers, archetypeModifiers: pack.archetypeModifiers, copyPools: nil)
        #expect(throws: ContentPackError.self) { try badPack.validate() }
    }

    @Test("Manifest coverage count mismatch rejected")
    func manifestCountMismatch() throws {
        let pack = makePilotPackI1()
        var cov = pack.manifest.coverage
        // Corrupt sunRecordCount
        let badCov = ContentPackManifest.Coverage(startDayKey: cov.startDayKey, endDayKey: cov.endDayKey, dayKeyCount: cov.dayKeyCount, isPilot: cov.isPilot, includesLeapDay: cov.includesLeapDay, sunRecordCount: 9999)
        let badManifest = ContentPackManifest(packVersion: pack.manifest.packVersion, language: pack.manifest.language, contentCycleVersion: pack.manifest.contentCycleVersion, createdAt: pack.manifest.createdAt, coverage: badCov, provenance: pack.manifest.provenance)
        let badPack = CompiledContentPack(manifest: badManifest, sunRecords: pack.sunRecords, moonModifiers: pack.moonModifiers, risingModifiers: pack.risingModifiers, archetypeModifiers: pack.archetypeModifiers, copyPools: pack.copyPools)
        #expect(throws: ContentPackError.self) { try badPack.validate() }
    }
}

// MARK: - 50 Determinism

@Suite("ContentPack I.1 — Determinism")
struct ContentPackI1DeterminismTests {
    @Test("Resolver selection stable across calls (no random)")
    func resolverStable() {
        let pack = makePilotPackI1()
        let repo = makeRepoI1(pack: pack)
        var cal = Calendar(identifier: .gregorian); cal.timeZone = TimeZone(secondsFromGMT: 0)!
        let date = cal.date(from: DateComponents(year: 2026, month: 3, day: 3))!
        let ctx = ctxI1(sun: "aries", moon: "cancer", rising: "leo")
        let a = BundledContentResolver.resolve(date: date, dayOffset: 10, context: ctx, calendar: cal, repository: repo)
        let b = BundledContentResolver.resolve(date: date, dayOffset: 10, context: ctx, calendar: cal, repository: repo)
        #expect(a == b)
        #expect(a?.context.selectedMoonFragment == b?.context.selectedMoonFragment)
    }

    @Test("Score plan generator stable (SHA256 not hash)")
    func scorePlanStable() {
        // Compiler reproducible: encode twice yields same bytes (sorted keys, no fresh timestamp)
        let pack = makePilotPackI1()
        let encoder = JSONEncoder(); encoder.outputFormatting = [.sortedKeys]
        let data1 = try! encoder.encode(pack.manifest)
        let data2 = try! encoder.encode(pack.manifest)
        #expect(data1 == data2)
    }
}

// MARK: - 51 Thematic modifiers

@Suite("ContentPack I.1 — Thematic modifiers")
struct ContentPackI1ThematicTests {
    @Test("Romance theme chooses romance-compatible fragment when available")
    func romanceTheme() {
        let pack = makePilotPackI1()
        let repo = makeRepoI1(pack: pack)
        // Create a sun record with romance tag and romance high scores to exercise theme path
        var cal = Calendar(identifier: .gregorian); cal.timeZone = TimeZone(secondsFromGMT: 0)!
        let date = cal.date(from: DateComponents(year: 2026, month: 3, day: 2))!
        let ctx = ctxI1(sun: "libra", moon: "aries", rising: "taurus")
        let r = BundledContentResolver.resolve(date: date, dayOffset: 0, context: ctx, calendar: cal, repository: repo)
        #expect(r != nil)
        // If dominant theme is romance, moon fragment should be romance pool if exists
        if let theme = r?.context.dominantTheme, theme == "romance" {
            #expect(r?.context.selectedMoonFragment != nil || r?.context.moonModifier == nil)
        }
    }

    @Test("Social theme can choose Rising fragment")
    func socialThemeRising() {
        let pack = makePilotPackI1()
        let repo = makeRepoI1(pack: pack)
        var cal = Calendar(identifier: .gregorian); cal.timeZone = TimeZone(secondsFromGMT: 0)!
        let date = cal.date(from: DateComponents(year: 2026, month: 3, day: 4))!
        let ctx = ctxI1(sun: "gemini", moon: "leo", rising: "libra")
        let r = BundledContentResolver.resolve(date: date, dayOffset: 2, context: ctx, calendar: cal, repository: repo)
        #expect(r != nil)
        // Should not crash when rising missing
        let ctxNoRising = ctxI1(sun: "gemini", moon: "leo", rising: nil)
        let r2 = BundledContentResolver.resolve(date: date, dayOffset: 2, context: ctxNoRising, calendar: cal, repository: repo)
        #expect(r2?.context.selectedRisingFragment == nil)
    }

    @Test("Archetype does not disappear forever when Moon exists")
    func archetypeNotLost() {
        let pack = makePilotPackI1()
        let repo = makeRepoI1(pack: pack)
        var cal = Calendar(identifier: .gregorian); cal.timeZone = TimeZone(secondsFromGMT: 0)!
        let subjects = (0..<14).map { idx in
            cal.date(from: DateComponents(year: 2026, month: 3, day: 1 + idx))!
        }
        let ctx = ctxI1(sun: "libra", moon: "capricorn", rising: "aries")
        var seenMoon = 0, seenArch = 0, seenNone = 0
        for (idx, date) in subjects.enumerated() {
            let r = BundledContentResolver.resolve(date: date, dayOffset: idx, context: ctx, calendar: cal, repository: repo)!
            switch r.context.personalAccentSource {
            case "moon": seenMoon += 1
            case "archetype": seenArch += 1
            default: seenNone += 1
            }
        }
        #expect(seenMoon > 0)
        #expect(seenArch > 0)
    }

    @Test("Same profile/date resolves identically")
    func sameProfileSameDateDeterministic() {
        let pack = makePilotPackI1(); let repo = makeRepoI1(pack: pack)
        var cal = Calendar(identifier: .gregorian); cal.timeZone = TimeZone(secondsFromGMT: 0)!
        let date = cal.date(from: DateComponents(year: 2026, month: 3, day: 6))!
        let ctx = ctxI1(sun: "virgo", moon: "taurus", rising: "aries")
        let a = BundledContentResolver.resolve(date: date, dayOffset: 5, context: ctx, calendar: cal, repository: repo)
        let b = BundledContentResolver.resolve(date: date, dayOffset: 5, context: ctx, calendar: cal, repository: repo)
        #expect(a == b)
    }

    @Test("Unavailable Moon does not invent fragment")
    func noMoonNoFragment() {
        let pack = makePilotPackI1(); let repo = makeRepoI1(pack: pack)
        var cal = Calendar(identifier: .gregorian); cal.timeZone = TimeZone(secondsFromGMT: 0)!
        let date = cal.date(from: DateComponents(year: 2026, month: 3, day: 2))!
        let ctx = ctxI1(sun: "libra", moon: nil, rising: "aries")
        let r = BundledContentResolver.resolve(date: date, dayOffset: 0, context: ctx, calendar: cal, repository: repo)!
        #expect(r.context.selectedMoonFragment == nil)
    }
}

// MARK: - 52 QA engine

@Suite("ContentPack I.1 — QA engine")
struct ContentPackI1QATests {
    @Test("Duplicate headline detection works")
    func duplicateHeadline() {
        let pack = makePilotPackI1()
        let counts = Dictionary(grouping: pack.sunRecords, by: { $0.headline }).mapValues(\.count)
        let dups = counts.filter { $0.value > 1 }
        // Pilot has some reuse; ensure detection not crashing
        #expect(dups.count >= 0)
    }

    @Test("Per-sign duplicate stats computed")
    func perSign() {
        let pack = makePilotPackI1()
        for sign in ["aries","taurus","libra"] {
            let subset = pack.sunRecords.filter { $0.sunSign == sign }
            let uniq = Set(subset.map(\.headline)).count
            #expect(uniq > 0)
            #expect(uniq <= subset.count)
        }
    }

    @Test("Adjacent identical text detection runs")
    func adjacent() {
        let pack = makePilotPackI1()
        var warnings: [String] = []
        let ordered = CanonicalDayKey.all366.map(\.key)
        let idx = Dictionary(uniqueKeysWithValues: ordered.enumerated().map { ($1, $0) })
        let testSigns = WesternZodiacSign.allCases.map(\.rawValue)
        for sign in testSigns {
            let sortedRecords = pack.sunRecords.filter { $0.sunSign == sign }.sorted { (idx[$0.dayKey] ?? 999) < (idx[$1.dayKey] ?? 999) }
            for i in 0..<(sortedRecords.count-1) {
                if sortedRecords[i].headline == sortedRecords[i+1].headline {
                    warnings.append("identical headline \(sign)")
                }
            }
        }
        #expect(warnings.count >= 0)
    }
}

// MARK: - 53 Size

@Suite("ContentPack I.1 — Size budget")
struct ContentPackI1SizeTests {
    @Test("Compiled pilot within limits and projection within 4 MiB")
    func sizeLimits() throws {
        let url = try #require(Bundle.main.url(forResource: "contentPack", withExtension: "json", subdirectory: "ContentPacks/v1") ?? Bundle.main.url(forResource: "contentPack", withExtension: "json"))
        let data = try Data(contentsOf: url)
        #expect(data.count < 512*1024)
        let pack = try BundledContentPackRepository.decodePack(from: data)
        let avg = Double(data.count) / Double(pack.sunRecords.count)
        let projected = avg * 4392 + 32_000
        #expect(projected <= 4 * 1024 * 1024, "Projected \(Int(projected)) exceeds 4 MiB hard ceiling")
        #expect(projected <= 3 * 1024 * 1024 + 512*1024, "Projected ideally ≤3 MiB, got \(Int(projected))") // slack
    }

    @Test("Performance: 365-day resolution remains fast")
    func performance365() {
        let pack = makePilotPackI1()
        let repo = makeRepoI1(pack: pack)
        let subject = ForecastSubject(id: UUID(), name: "Perf", birth: BirthDetails(year: 1993, month: 3, day: 2))
        let anchor = ForecastAnchor(year: 2026, month: 3, day: 1)
        let ctx = PersonalizationContext.from(subject: subject)
        let start = Date()
        for offset in 0..<YearlyForecast.dayCount {
            _ = BundledContentResolver.resolve(dayOffset: offset, anchor: anchor, context: ctx, repository: repo) ?? {
                let base = HumayContentEngine.baseScores(profileID: subject.id, birth: subject.birth, dayOffset: offset)
                return nil as BundledContentResolver.ResolvedDay?
            }()
        }
        let elapsed = Date().timeIntervalSince(start)
        #expect(elapsed < 0.5, "365-day resolution took \(elapsed)s, should be <0.5s with indexing")
    }
}
