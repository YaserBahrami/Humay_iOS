#if DEBUG
import Foundation

/// Deterministic fixtures for Phase G development and tests (§38).
///
/// All documents here are built synchronously from the deterministic provider's
/// static helpers — no network, no actor hops — so they are usable in previews
/// and Swift Testing without async ceremony.
enum DevelopmentForecastFixtures {
    /// Profile A — complete full year, Sun sign Leo.
    static func profileA() -> PersonalizedForecastDocument {
        build(
            subject: ForecastSubject(
                id: UUID(uuidString: "aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa")!,
                name: "Profile A",
                birth: BirthDetails(year: 1993, month: 8, day: 7)
            ),
            anchor: ForecastAnchor(year: 2026, month: 8, day: 26),
            mode: .complete
        )
    }

    /// Profile B — complete year with a visibly different curve, Sun sign Gemini.
    static func profileB() -> PersonalizedForecastDocument {
        build(
            subject: ForecastSubject(
                id: UUID(uuidString: "bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb")!,
                name: "Profile B",
                birth: BirthDetails(year: 1995, month: 6, day: 3)
            ),
            anchor: ForecastAnchor(year: 2026, month: 8, day: 26),
            mode: .complete
        )
    }

    /// Partial — 6 months generated, 6 pending, phase .partial.
    static func partial() -> PersonalizedForecastDocument {
        build(
            subject: ForecastSubject(
                id: UUID(uuidString: "cccccccc-cccc-4ccc-8ccc-cccccccccccc")!,
                name: "Partial",
                birth: BirthDetails(year: 1990, month: 1, day: 15)
            ),
            anchor: ForecastAnchor(year: 2026, month: 8, day: 26),
            mode: .partial(upToMonthIndex: 5)
        )
    }

    /// Failed — one chunk failed (month 5), the rest complete.
    static func failed() -> PersonalizedForecastDocument {
        build(
            subject: ForecastSubject(
                id: UUID(uuidString: "dddddddd-dddd-4ddd-8ddd-dddddddddddd")!,
                name: "Failed",
                birth: BirthDetails(year: 1988, month: 11, day: 21)
            ),
            anchor: ForecastAnchor(year: 2026, month: 8, day: 26),
            mode: .failed(monthIndex: 5)
        )
    }

    /// Unknown birth time — Sun sign available, fingerprint reflects unknown time.
    static func unknownBirthTime() -> PersonalizedForecastDocument {
        build(
            subject: ForecastSubject(
                id: UUID(uuidString: "eeeeeeee-eeee-4eee-8eee-eeeeeeeeeeee")!,
                name: "Unknown Time",
                birth: BirthDetails(year: 1994, month: 3, day: 14)
            ),
            anchor: ForecastAnchor(year: 2026, month: 8, day: 26),
            mode: .complete
        )
    }

    // MARK: - Builder

    enum Mode {
        case complete
        case partial(upToMonthIndex: Int)
        case failed(monthIndex: Int)
    }

    private static func build(
        subject: ForecastSubject,
        anchor: ForecastAnchor,
        mode: Mode
    ) -> PersonalizedForecastDocument {
        let context = DeterministicContentProvider.yearContext(subject: subject, anchor: anchor)
        var days: [DailyMood] = []
        var chunks: [GenerationChunkState] = []

        for monthIndex in 0..<12 {
            let offsets = anchor.dayOffsets(inMonthIndex: monthIndex, totalDays: YearlyForecast.dayCount)

            let status: GenerationChunkStatus
            let completedAt: Date?

            switch mode {
            case .complete:
                status = .complete; completedAt = .now
            case .partial(let upTo):
                if monthIndex <= upTo { status = .complete; completedAt = .now }
                else { status = .pending; completedAt = nil }
            case .failed(let failedIndex):
                if monthIndex == failedIndex { status = .failed; completedAt = nil }
                else { status = .complete; completedAt = .now }
            }

            chunks.append(GenerationChunkState(
                monthIndex: monthIndex,
                status: status,
                attempts: status == .complete ? 1 : (status == .failed ? 2 : 0),
                lastFailure: status == .failed ? .serverError : nil,
                completedAt: completedAt
            ))

            guard status == .complete else { continue }

            var monthRNG = HumayContentEngine.makeRNG("fixture", subject.id.uuidString, String(monthIndex))
            for offset in offsets {
                days.append(DeterministicContentProvider.enrichedDay(
                    subject: subject,
                    anchor: anchor,
                    dayOffset: offset,
                    outline: context,
                    rng: &monthRNG
                ))
            }
        }

        days.sort { $0.dayOffset < $1.dayOffset }

        let phase: ForecastGenerationPhase = switch mode {
        case .complete: .complete
        case .partial: .partial
        case .failed: .failed
        }

        let fingerprint = ProfileFingerprint(subject: subject, generatorVersion: DeterministicContentProvider.generatorVersion)
        let state = GenerationStateRecord(
            phase: phase,
            chunks: chunks,
            fingerprintAtGeneration: fingerprint,
            generatorVersion: DeterministicContentProvider.generatorVersion,
            startedAt: .now,
            completedAt: phase == .complete ? .now : nil,
            requestCount: chunks.filter { $0.status == .complete }.count + 1,
            retryCount: chunks.contains(where: { $0.lastFailure != nil }) ? 1 : 0
        )

        return PersonalizedForecastDocument(
            subject: subject,
            anchor: anchor,
            provenance: .init(
                generatorVersion: DeterministicContentProvider.generatorVersion,
                providerIdentifier: DeterministicContentProvider.identifier,
                basis: .entertainmentFixture
            ),
            generationState: state,
            yearContext: context,
            days: days
        )
    }
}
#endif
