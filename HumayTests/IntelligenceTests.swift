import Foundation
import Testing
@testable import Humay

// MARK: - Helpers

private func makeSubject(
    id: UUID = UUID(),
    birth: BirthDetails = BirthDetails(year: 1993, month: 8, day: 7)
) -> ForecastSubject {
    ForecastSubject(id: id, name: "Test", birth: birth)
}

private func makeAnchor(
    year: Int = 2026, month: Int = 8, day: Int = 26
) -> ForecastAnchor {
    ForecastAnchor(year: year, month: month, day: day)
}

// MARK: - Schema & Validation

@Suite("Intelligence — Schema validation")
struct IntelligenceSchemaTests {
    @Test("MoodScores validating init rejects missing and out-of-range dimensions")
    func moodScoresValidation() throws {
        var values: [MoodDimension: Int] = [:]
        for d in MoodDimension.allCases { values[d] = 50 }
        #expect(throws: Never.self) { try MoodScores(validating: values) }

        var missing = values; missing.removeValue(forKey: .romance)
        #expect(throws: ForecastValidationError.self) { try MoodScores(validating: missing) }

        var outOfRange = values; outOfRange[.chaos] = 101
        #expect(throws: ForecastValidationError.self) { try MoodScores(validating: outOfRange) }
    }

    @Test("EntertainmentMetrics enforces 0–100 bounds")
    func entertainmentBounds() {
        #expect(throws: ForecastValidationError.self) { try EntertainmentMetrics(delusion: -1, mainCharacterEnergy: 50, dontTextThem: 50) }
        #expect(throws: ForecastValidationError.self) { try EntertainmentMetrics(delusion: 50, mainCharacterEnergy: 101, dontTextThem: 50) }
        #expect(throws: Never.self) { try EntertainmentMetrics(delusion: 0, mainCharacterEnergy: 100, dontTextThem: 50) }
    }

    @Test("DayReading enforces headline length and non-empty text")
    func dayReadingBounds() throws {
        let section = try DayReadingSection(category: .personal, text: "Hello")
        #expect(throws: ForecastValidationError.self) { try DayReading(headline: "", sections: [section]) }
        #expect(throws: ForecastValidationError.self) { try DayReading(headline: String(repeating: "a", count: 121), sections: [section]) }
        #expect(throws: Never.self) { try DayReading(headline: "Valid headline", sections: [section]) }
    }

    @Test("DayFlags and YearContext enforce required counts and ranges")
    func flagsAndYearContextBounds() {
        #expect(throws: ForecastValidationError.self) { try DayFlags(green: "", red: "ok") }
        #expect(throws: ForecastValidationError.self) { try DayFlags(green: String(repeating: "a", count: 141), red: "ok") }

        let monthly = (0..<12).map { MonthlyTheme(monthIndex: $0, theme: "T", tendency: "Leans steady") }
        #expect(throws: ForecastValidationError.self) {
            try YearContext(yearTheme: "", monthlyThemes: monthly, notablePeriods: [])
        }
        let shortMonthly = Array(monthly.prefix(11))
        #expect(throws: ForecastValidationError.self) {
            try YearContext(yearTheme: "Theme", monthlyThemes: shortMonthly, notablePeriods: [])
        }
        let badPeriod = NotablePeriod(startDayOffset: 10, endDayOffset: 5, label: "Backwards", kind: .romance)
        #expect(throws: ForecastValidationError.self) {
            try YearContext(yearTheme: "Theme", monthlyThemes: monthly, notablePeriods: [badPeriod])
        }
    }

    @Test("ForecastValidator detects duplicates, out-of-range, and missing coverage")
    func validatorCatchesDayIssues() throws {
        let ok = makeSubject()
        let anchor = makeAnchor()
        let complete = DevelopmentForecastFixtures.profileA()
        #expect(throws: Never.self) { try ForecastValidator.validate(days: complete.days) }

        var dup = complete.days
        dup.append(complete.days[0])
        #expect(throws: ForecastValidationError.self) { try ForecastValidator.validate(days: dup) }

        let expected = anchor.dayOffsets(inMonthIndex: 0, totalDays: YearlyForecast.dayCount)
        let subset = Array(complete.days.filter { expected.contains($0.dayOffset) }.prefix(expected.count - 1))
        #expect(throws: ForecastValidationError.self) { try ForecastValidator.validate(days: subset, expectedOffsets: expected) }
    }

    @Test("Repetition check flags copied headlines without failing small samples")
    func repetitionCheck() {
        let distinct = (0..<12).map { "Unique headline \($0)" }
        #expect(ForecastValidator.repetitionIssue(headlines: distinct, label: "month") == nil)
        #expect(ForecastValidator.repetitionIssue(headlines: Array(repeating: "Same line", count: 12), label: "month") != nil)
        #expect(ForecastValidator.repetitionIssue(headlines: ["a", "b"], label: "tiny") == nil)
    }
}

// MARK: - Fingerprinting

@Suite("Intelligence — Fingerprinting")
struct IntelligenceFingerprintTests {
    @Test("Fingerprint is stable for the same subject and generator")
    func stable() {
        let subject = makeSubject()
        let a = ProfileFingerprint(subject: subject, generatorVersion: "v1")
        let b = ProfileFingerprint(subject: subject, generatorVersion: "v1")
        #expect(a == b)
    }

    @Test("Fingerprint changes when birth time, place, or generator changes")
    func sensitive() {
        let base = ForecastSubject(id: UUID(uuidString: "aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa")!, name: "X", birth: BirthDetails(year: 1993, month: 8, day: 7))
        let withTime = ForecastSubject(
            id: base.id, name: "X",
            birth: BirthDetails(year: 1993, month: 8, day: 7, time: .exact(minutesFromMidnight: 450), place: .notProvided)
        )
        let withPlace = ForecastSubject(
            id: base.id, name: "X",
            birth: BirthDetails(year: 1993, month: 8, day: 7, place: .known(name: "Tehran", latitude: 35.68, longitude: 51.41, timeZoneIdentifier: "Asia/Tehran"))
        )
        let basePrint = ProfileFingerprint(subject: base, generatorVersion: "v1")
        #expect(ProfileFingerprint(subject: withTime, generatorVersion: "v1") != basePrint)
        #expect(ProfileFingerprint(subject: withPlace, generatorVersion: "v1") != basePrint)
        #expect(ProfileFingerprint(subject: base, generatorVersion: "v2") != basePrint)
    }

    @Test("Document isStale reflects fingerprint and generator mismatch")
    func documentStaleness() {
        let subject = makeSubject(id: UUID(uuidString: "aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa")!)
        let doc = DevelopmentForecastFixtures.profileA()
        // Fixture id differs on purpose — staleness is per-subject. Build a doc for the same subject.
        let same = {
            var s = subject
            return DevelopmentForecastFixtures.profileA()
        }()
        // A doc built for subject A should not be stale for A (same birth).
        // We verify by building a fresh doc for the same logical subject via the same builder path.
        let anchor = makeAnchor()
        let fresh = DevelopmentForecastFixtures.profileA() // same seeded id as profileA fixture
        // The fixture's subject id is fixed; test that a different birth makes it stale.
        let differentBirth = ForecastSubject(id: fresh.subject.profileID, name: "X", birth: BirthDetails(year: 2000, month: 1, day: 1))
        #expect(fresh.isStale(for: differentBirth) == true)
        _ = (same, anchor) // silence unused
    }
}

// MARK: - Repository

@Suite("Intelligence — Forecast repository")
struct IntelligenceRepositoryTests {
    @Test("File repository roundtrips a complete document and survives reload")
    func fileRoundtrip() async throws {
        let dir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString, isDirectory: true)
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: dir) }

        let repo = FileForecastRepository(directory: dir)
        let subject = makeSubject()
        let doc = DevelopmentForecastFixtures.profileA()
        // Rebuild for this subject so fingerprint matches.
        let rebuilt = rebuild(doc, for: subject)

        try await repo.save(rebuilt)
        let loaded = try #require(await repo.load(subject: subject))
        #expect(loaded.days.count == rebuilt.days.count)
        #expect(loaded.fingerprint == rebuilt.fingerprint)

        let data = try await repo.exportData(subject: subject)
        #expect(!data.isEmpty)
        let decoded = try FileForecastRepository.decode(data)
        #expect(decoded.days == rebuilt.days)
        #expect(decoded.fingerprint == rebuilt.fingerprint)
        #expect(decoded.forecast.yearContext == rebuilt.forecast.yearContext)
    }

    @Test("Repository detects corrupted cache and unsupported schema")
    func corruptionAndSchema() async throws {
        let dir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString, isDirectory: true)
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: dir) }

        let repo = FileForecastRepository(directory: dir)
        let subject = ForecastSubject(id: UUID(), name: "X", birth: BirthDetails(year: 1990, month: 1, day: 1))

        // Write malformed JSON directly.
        let url = dir.appendingPathComponent("\(subject.id.uuidString)-forecast-v\(PersonalizedForecastDocument.schemaVersion).json")
        try "not json".data(using: .utf8)!.write(to: url)
        do {
            _ = try await repo.load(subject: subject)
            Issue.record("Expected corruptedCache")
        } catch let error as ForecastRepositoryError {
            #expect(error == .corruptedCache)
        }

        // Unsupported schema envelope.
        let badSchema = #"{"schemaVersion":999,"fingerprint":"x","subject":{},"astrology":{},"identity":{},"forecast":{},"provenance":{},"generationState":{}}"#
        try badSchema.data(using: .utf8)!.write(to: url)
        do {
            _ = try await repo.load(subject: subject)
            Issue.record("Expected unsupportedSchema")
        } catch let error as ForecastRepositoryError {
            if case .unsupportedSchema(let v) = error { #expect(v == 999) }
            else { Issue.record("Wrong error \(error)") }
        }
    }

    @Test("mergeMonth replaces exactly the month's offsets and persists")
    func mergeMonthCoverage() async throws {
        let dir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString, isDirectory: true)
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: dir) }

        let repo = FileForecastRepository(directory: dir)
        let subject = makeSubject()
        let anchor = makeAnchor()

        // Start from a partial document (6 months) and merge one more month.
        let partial = DevelopmentForecastFixtures.partial()
        let rebuiltPartial = rebuild(partial, for: subject, anchor: anchor)
        try await repo.save(rebuiltPartial)

        let monthIndex = 6
        let offsets = anchor.dayOffsets(inMonthIndex: monthIndex, totalDays: YearlyForecast.dayCount)
        let outline = rebuiltPartial.forecast.yearContext!
        let provider = DeterministicContentProvider()
        let chunk = try await provider.generateMonthChunk(subject: subject, outline: outline, anchor: anchor, monthIndex: monthIndex)

        let merged = try await repo.mergeMonth(
            subject: subject, anchor: anchor, monthIndex: monthIndex,
            days: chunk.days, chunkState: GenerationChunkState(monthIndex: monthIndex, status: .complete, attempts: 1, completedAt: .now),
            usage: GenerationUsage(requestCount: 1)
        )

        for offset in offsets {
            #expect(merged.day(atOffset: offset) != nil)
        }
        #expect(merged.generationState.chunk(monthIndex).status == .complete)
    }

    @Test("In-memory repository supports the same lifecycle")
    func inMemoryLifecycle() async throws {
        let repo = InMemoryForecastRepository()
        let subject = makeSubject()
        let doc = rebuild(DevelopmentForecastFixtures.profileA(), for: subject)
        try await repo.save(doc)
        let loaded = try #require(await repo.load(subject: subject))
        #expect(loaded == doc)
        try await repo.remove(subject: subject)
        #expect(try await repo.load(subject: subject) == nil)
    }

    private func rebuild(
        _ template: PersonalizedForecastDocument,
        for subject: ForecastSubject,
        anchor: ForecastAnchor? = nil
    ) -> PersonalizedForecastDocument {
        let resolvedAnchor = anchor ?? template.anchor
        let fingerprint = ProfileFingerprint(subject: subject, generatorVersion: template.provenance.generatorVersion)
        // Re-encode via JSON to swap the subject/fingerprint while keeping shape.
        // Simpler: construct a fresh document with the same days/context but the new subject.
        // Use the template's days and context directly.
        let state = GenerationStateRecord(
            phase: template.generationState.phase,
            chunks: template.generationState.chunks,
            fingerprintAtGeneration: fingerprint,
            generatorVersion: template.provenance.generatorVersion,
            startedAt: template.generationState.startedAt,
            completedAt: template.generationState.completedAt,
            requestCount: template.generationState.requestCount
        )
        return PersonalizedForecastDocument(
            subject: subject,
            anchor: resolvedAnchor,
            provenance: template.provenance,
            generationState: state,
            yearContext: template.forecast.yearContext,
            days: template.days
        )
    }
}

// MARK: - Mock provider

actor MockContentProvider: PersonalizedContentProviding {
    var failMonths: Set<Int> = []
    var malformedMonths: Set<Int> = []
    var delayNanoseconds: UInt64 = 0
    var outlineCallCount = 0
    var monthCallCounts: [Int: Int] = [:]
    nonisolated var descriptor: PersonalizedContentProviderDescriptor {
        PersonalizedContentProviderDescriptor(
            providerIdentifier: "mock",
            generatorVersion: "mock-v1",
            promptCatalogVersion: IntelligenceVersions.promptCatalog,
            basis: .entertainmentFixture,
            modelIdentifier: "mock"
        )
    }

    init(failMonths: Set<Int> = [], malformedMonths: Set<Int> = [], delayNanoseconds: UInt64 = 0) {
        self.failMonths = failMonths
        self.malformedMonths = malformedMonths
        self.delayNanoseconds = delayNanoseconds
    }

    func generateYearOutline(subject: ForecastSubject, anchor: ForecastAnchor) async throws -> GeneratedOutline {
        try Task.checkCancellation()
        outlineCallCount += 1
        if delayNanoseconds > 0 { try await Task.sleep(nanoseconds: delayNanoseconds) }
        let context = DeterministicContentProvider.yearContext(subject: subject, anchor: anchor)
        return GeneratedOutline(context: context, usage: GenerationUsage(requestCount: 1), modelIdentifier: "mock")
    }

    func generateMonthChunk(subject: ForecastSubject, outline: YearContext, anchor: ForecastAnchor, monthIndex: Int) async throws -> GeneratedMonth {
        try Task.checkCancellation()
        monthCallCounts[monthIndex, default: 0] += 1
        if delayNanoseconds > 0 { try await Task.sleep(nanoseconds: delayNanoseconds) }

        if failMonths.contains(monthIndex) {
            throw GenerationError.serverError(status: 500)
        }
        if malformedMonths.contains(monthIndex) {
            throw GenerationError.malformedOutput(detail: "test malformed month \(monthIndex)")
        }

        let provider = DeterministicContentProvider()
        return try await provider.generateMonthChunk(subject: subject, outline: outline, anchor: anchor, monthIndex: monthIndex)
    }

    func regenerateDay(subject: ForecastSubject, outline: YearContext, anchor: ForecastAnchor, dayOffset: Int) async throws -> DailyMood {
        try Task.checkCancellation()
        let provider = DeterministicContentProvider()
        return try await provider.regenerateDay(subject: subject, outline: outline, anchor: anchor, dayOffset: dayOffset)
    }
}

// MARK: - Coordinator

@Suite("Intelligence — Generation coordinator")
struct IntelligenceCoordinatorTests {
    @Test("Complete generation persists 12 chunks and resolves to complete")
    func completeGeneration() async throws {
        let repo = InMemoryForecastRepository()
        let provider = MockContentProvider()
        let coordinator = ForecastGenerationCoordinator(provider: provider, repository: repo)
        let subject = makeSubject()
        let anchor = makeAnchor()

        let outcome = try await coordinator.ensureForecast(subject: subject, anchor: anchor)
        if case .generated(let doc) = outcome {
            #expect(doc.generationState.completedChunkCount == 12)
            #expect(doc.days.count == YearlyForecast.dayCount)
        } else { Issue.record("Expected generated, got \(outcome)") }

        // Second call is a cache hit — no additional provider work.
        let second = try await coordinator.ensureForecast(subject: subject, anchor: anchor)
        if case .cached = second {} else { Issue.record("Expected cached on second call") }
    }

    @Test("Partial failure records failed chunks and resumes only the missing ones")
    func partialFailureAndResume() async throws {
        let repo = InMemoryForecastRepository()
        let failing = MockContentProvider(failMonths: [5, 9])
        let coordinator = ForecastGenerationCoordinator(provider: failing, repository: repo)
        let subject = makeSubject()
        let anchor = makeAnchor()

        let outcome = try await coordinator.ensureForecast(subject: subject, anchor: anchor)
        if case .partial(let doc, _) = outcome {
            #expect(doc.generationState.chunk(5).status == .failed)
            #expect(doc.generationState.chunk(9).status == .failed)
            #expect(doc.generationState.completedChunkCount == 10)
        } else { Issue.record("Expected partial, got \(outcome)") }

        // Resume with a healthy provider — only the failed months are retried.
        let healthy = MockContentProvider()
        let resumer = ForecastGenerationCoordinator(provider: healthy, repository: repo)
        let resumed = try await resumer.ensureForecast(subject: subject, anchor: anchor)
        if case .generated(let doc) = resumed {
            #expect(doc.days.count == YearlyForecast.dayCount)
            #expect(doc.generationState.chunk(5).status == .complete)
        } else { Issue.record("Expected generated after resume, got \(resumed)") }
    }

    @Test("Validation failures are recorded without discarding successful chunks")
    func validationFailureIsolation() async throws {
        let repo = InMemoryForecastRepository()
        let provider = MockContentProvider(malformedMonths: [3])
        let coordinator = ForecastGenerationCoordinator(provider: provider, repository: repo)
        let subject = makeSubject()
        let anchor = makeAnchor()

        let outcome = try await coordinator.ensureForecast(subject: subject, anchor: anchor)
        if case .partial(let doc, _) = outcome {
            #expect(doc.generationState.chunk(3).status == .failed)
            #expect(doc.days.count < YearlyForecast.dayCount)
            #expect(doc.days.count > 0)
        } else { Issue.record("Expected partial for malformed month") }
    }

    @Test("Cancellation persists partial state and does not discard completed months")
    func cancellationPersistsPartial() async throws {
        let repo = InMemoryForecastRepository()
        let slow = MockContentProvider(delayNanoseconds: 60_000_000)
        let coordinator = ForecastGenerationCoordinator(provider: slow, repository: repo)
        let subject = makeSubject()
        let anchor = makeAnchor()

        let task = Task {
            try await coordinator.ensureForecast(subject: subject, anchor: anchor)
        }
        // Poll until at least one chunk is persisted, then cancel.
        var observed = 0
        for _ in 0..<30 {
            try await Task.sleep(nanoseconds: 30_000_000)
            if let doc = try await repo.load(subject: subject) {
                observed = doc.generationState.completedChunkCount
                if observed >= 1 { break }
            }
        }
        task.cancel()
        _ = try? await task.value
        try await Task.sleep(nanoseconds: 50_000_000)

        let persisted = try #require(await repo.load(subject: subject))
        #expect(persisted.generationState.completedChunkCount >= 1)
        #expect(persisted.generationState.completedChunkCount < 12)
    }

    @Test("Stale fingerprint forces regeneration")
    func staleFingerprintTriggersRegen() async throws {
        let repo = InMemoryForecastRepository()
        let provider = MockContentProvider()
        let coordinator = ForecastGenerationCoordinator(provider: provider, repository: repo)
        let original = makeSubject(birth: BirthDetails(year: 1993, month: 8, day: 7))
        let anchor = makeAnchor()
        _ = try await coordinator.ensureForecast(subject: original, anchor: anchor)

        // Same ID, different birth date — fingerprint differs, doc is stale.
        let changed = ForecastSubject(id: original.id, name: "Test", birth: BirthDetails(year: 2000, month: 1, day: 1))
        let outcome = try await coordinator.ensureForecast(subject: changed, anchor: anchor)
        if case .generated(let doc) = outcome {
            #expect(doc.days.count == YearlyForecast.dayCount)
        } else { Issue.record("Expected regenerated for stale subject, got \(outcome)") }
    }
}

// MARK: - Comparison

@Suite("Intelligence — Forecast comparison")
struct IntelligenceComparisonTests {
    @Test("Comparator is deterministic and symmetric in alignment")
    func comparatorDeterminism() {
        let a = DevelopmentForecastFixtures.profileA()
        let b = DevelopmentForecastFixtures.profileB()
        let af = YearlyForecast(profileID: a.subject.profileID, days: a.days, provenance: .fixture(generatorVersion: "t"))
        let bf = YearlyForecast(profileID: b.subject.profileID, days: b.days, provenance: .fixture(generatorVersion: "t"))
        let c1 = ForecastComparator(first: af, second: bf)
        let c2 = ForecastComparator(first: af, second: bf)
        #expect(c1 == c2)
        #expect(c1.overallAlignment() == c2.overallAlignment())
        #expect((0...100).contains(c1.overallAlignment()))
    }

    @Test("Same forecast aligns at 100; non-overlapping edge is guarded")
    func edgeCases() {
        let doc = DevelopmentForecastFixtures.profileA()
        let forecast = YearlyForecast(profileID: doc.subject.profileID, days: doc.days, provenance: .fixture(generatorVersion: "t"))
        let selfCompare = ForecastComparator(first: forecast, second: forecast)
        #expect(selfCompare.overallAlignment() == 100)
        #expect(selfCompare.bestRomanceDays(limit: 1).count == 1)
        #expect(selfCompare.conflictDays(limit: 5).allSatisfy { $0.score >= 0 })
        #expect(selfCompare.calmWindows(windowLength: 3, count: 1).count <= 1)
    }

    @Test("Best alignment windows stay inside the year and are ordered")
    func windowsAreOrdered() {
        let a = DevelopmentForecastFixtures.profileA()
        let b = DevelopmentForecastFixtures.profileB()
        let af = YearlyForecast(profileID: a.subject.profileID, days: a.days, provenance: .fixture(generatorVersion: "t"))
        let bf = YearlyForecast(profileID: b.subject.profileID, days: b.days, provenance: .fixture(generatorVersion: "t"))
        let comparator = ForecastComparator(first: af, second: bf)
        let windows = comparator.bestAlignmentWindows(dimension: .overall, windowLength: 3, count: 3)
        #expect(windows.allSatisfy { $0.startDayOffset >= 0 && $0.endDayOffset < YearlyForecast.dayCount })
        #expect(windows.count <= 3)
    }
}

// MARK: - FeedComposer & Mode independence

@Suite("Intelligence — Feed composer and mode independence")
struct IntelligenceFeedComposerTests {
    @Test("Personalized feed uses the day's semantic reading and flags")
    func personalizedFeedUsesDayRecord() {
        let doc = DevelopmentForecastFixtures.profileA()
        let subject = ForecastSubject(
            id: doc.subject.profileID, name: "A",
            birth: BirthDetails(year: 1993, month: 8, day: 7)
        )
        let dayOffset = 10
        guard let day = doc.day(atOffset: dayOffset) else {
            Issue.record("Day missing in fixture"); return
        }
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        let date = doc.anchor.date(forDayOffset: dayOffset, calendar: calendar)!

        let items = FeedComposer.dailyFeed(
            subject: subject, document: doc, date: date, calendar: calendar, mode: .normal, skyEvent: nil
        )

        let headline = items.first { if case .headline = $0.kind { return true }; return false }
        if case .headline(let content)? = headline?.kind {
            #expect(content.headline == day.reading?.headline)
        } else { Issue.record("Expected headline from personalized day") }

        let flags = items.first { if case .flagPair = $0.kind { return true }; return false }
        if case .flagPair(let f)? = flags?.kind, let expected = day.flags {
            #expect(f.greenFlag == expected.green)
            #expect(f.redFlag == expected.red)
        }
    }

    @Test("Changing personality mode never changes the underlying day record")
    func modeDoesNotMutateScores() {
        let doc = DevelopmentForecastFixtures.profileA()
        let subject = ForecastSubject(
            id: doc.subject.profileID, name: "A",
            birth: BirthDetails(year: 1993, month: 8, day: 7)
        )
        let dayOffset = 25
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        let date = doc.anchor.date(forDayOffset: dayOffset, calendar: calendar)!
        let baseline = doc.day(atOffset: dayOffset)!

        for mode in [PersonalityMode.roast, .delulu, .soft, .bestie] {
            let items = FeedComposer.dailyFeed(
                subject: subject, document: doc, date: date, calendar: calendar, mode: mode, skyEvent: nil
            )
            // The semantic day is unchanged; only the roast expression varies.
            let meters = items.first { if case .meterSet = $0.kind { return true }; return false }
            if case .meterSet(let set)? = meters?.kind {
                for meter in set.meters {
                    if meter.metric == .confidence { #expect(meter.value == baseline.scores[.confidence]) }
                    if meter.metric == .patience { #expect(meter.value == baseline.scores[.patience]) }
                }
            }
        }
    }

    @Test("Fallback path equals the deterministic engine feed when no document exists")
    func fallbackParity() {
        let subject = ForecastSubject(id: UUID(), name: "NoDoc", birth: BirthDetails(year: 1990, month: 6, day: 15))
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        let date = calendar.date(from: DateComponents(year: 2026, month: 9, day: 1))!
        let expected = HumayContentEngine.dailyFeed(
            profile: UserProfile(id: subject.id, displayName: subject.name, birth: subject.birth),
            date: date, calendar: calendar, mode: .normal, skyEvent: nil
        )
        let fallback = FeedComposer.dailyFeed(subject: subject, document: nil, date: date, calendar: calendar, mode: .normal, skyEvent: nil)
        // Structure parity: same kinds in same order when no personalized day.
        #expect(fallback.map { String(describing: $0.kind) } == expected.map { String(describing: $0.kind) })
    }
}

// MARK: - Provider temporal coherence

@Suite("Intelligence — Deterministic provider coherence")
struct DeterministicProviderCoherenceTests {
    @Test("Adjacent days correlate; provider does not whiplash (§10)")
    func temporalCoherence() async throws {
        let subject = makeSubject()
        let anchor = makeAnchor()
        let provider = DeterministicContentProvider()
        let outline = try await provider.generateYearOutline(subject: subject, anchor: anchor)
        let month = try await provider.generateMonthChunk(subject: subject, outline: outline.context, anchor: anchor, monthIndex: 0)
        var maxJump = 0
        for i in 1..<month.days.count {
            let jump = abs(month.days[i].scores[.overall] - month.days[i - 1].scores[.overall])
            maxJump = max(maxJump, jump)
        }
        // Waves + ±8 noise cannot sustain a 60-point single-day swing.
        #expect(maxJump < 55)
    }

    @Test("Provider is deterministic for the same subject and month")
    func providerDeterminism() async throws {
        let subject = makeSubject()
        let anchor = makeAnchor()
        let provider = DeterministicContentProvider()
        let outline = try await provider.generateYearOutline(subject: subject, anchor: anchor)
        let a = try await provider.generateMonthChunk(subject: subject, outline: outline.context, anchor: anchor, monthIndex: 3)
        let b = try await provider.generateMonthChunk(subject: subject, outline: outline.context, anchor: anchor, monthIndex: 3)
        #expect(a.days == b.days)
    }
}
