import Foundation
import Testing
@testable import Humay

/// The executable form of the rule in `MOCK_DATA_STRATEGY.md`.
///
/// Every value returned by every mock service must declare mock provenance. A new mock
/// method that forgets to go through the boundary fails here rather than shipping a
/// fixture that looks calculated.
@MainActor
@Suite("Mock provenance")
struct MockProvenanceTests {
    private let date = DateComponents(year: 2026, month: 8, day: 11)
    private let profile = UserProfile(
        displayName: "Test",
        birth: BirthDetails(
            year: 1994,
            month: 3,
            day: 14,
            time: .exact(minutesFromMidnight: 462),
            place: .known(name: "Lisbon", latitude: 38.7, longitude: -9.1, timeZoneIdentifier: "Europe/Lisbon")
        )
    )

    @Test("every general reading is marked", arguments: WesternSign.allCases)
    func generalReadings(_ sign: WesternSign) async throws {
        let service = MockHoroscopeService(latency: .instant)
        for tone in Tone.allCases {
            let reading = try await service.generalReading(sign: sign, date: date, tone: tone)
            #expect(reading.provenance.isMock)
        }
    }

    @Test("precise readings are marked")
    func preciseReading() async throws {
        let reading = try await MockHoroscopeService(latency: .instant)
            .preciseReading(profile: profile, date: date, tone: .normal)
        #expect(reading.provenance.isMock)
    }

    @Test("charts are marked in every system", arguments: ChartSystem.allCases)
    func charts(_ system: ChartSystem) async throws {
        let service = MockChartCalculationService(latency: .instant)
        let chart = try await service.chart(for: profile.birth, system: system)
        #expect(chart.provenance.isMock)

        let signProfile = try await service.signProfile(for: profile.birth)
        #expect(signProfile.provenance.isMock)
    }

    @Test("sky content is marked")
    func sky() async throws {
        let service = MockSkyService(latency: .instant)
        let snapshot = try await service.snapshot(for: date, profile: profile)
        #expect(snapshot.provenance.isMock)
        for event in snapshot.upcoming {
            #expect(event.provenance.isMock)
        }
    }

    @Test("compatibility readings are marked")
    func compatibility() async throws {
        let service = MockCompatibilityService(latency: .instant)
        let general = try await service.generalReading(.pisces, .leo, tone: .normal)
        #expect(general.provenance.isMock)

        let person = CirclePerson(name: "Sara", role: .partner, birth: BirthDetails(year: 1993, month: 8, day: 3))
        let precise = try await service.preciseReading(user: profile, person: person, tone: .normal)
        #expect(precise.provenance.isMock)

        let together = try await service.todayTogether(user: profile, person: person, date: date, tone: .normal)
        #expect(together.provenance.isMock)
    }

    @Test("answers are marked")
    func ask() async throws {
        let service = MockAstrologyAssistantService(latency: .instant)
        let answer = try await service.answer(
            question: "Why does this feel stuck?",
            in: AskConversation(),
            profile: profile,
            tone: .normal
        )
        #expect(answer.provenance.isMock)
    }
}

/// Roast changes expression only.
///
/// Both registers are read from one fixture that holds a single basis, so there is no
/// code path in which choosing Roast changes what the chart is held to say. This asserts
/// that structurally rather than trusting it.
@MainActor
@Suite("Tone invariance")
struct ToneInvarianceTests {
    @Test("basis is identical across registers", arguments: WesternSign.allCases)
    func basisIsShared(_ sign: WesternSign) async throws {
        let service = MockHoroscopeService(latency: .instant)
        let date = DateComponents(year: 2026, month: 8, day: 11)

        let normal = try await service.generalReading(sign: sign, date: date, tone: .normal)
        let roast = try await service.generalReading(sign: sign, date: date, tone: .roast)

        #expect(normal.basis == roast.basis)
        #expect(normal.subjectLabel == roast.subjectLabel)
        #expect(normal.tier == roast.tier)
    }

    @Test("the registers actually differ", arguments: WesternSign.allCases)
    func registersDiffer(_ sign: WesternSign) async throws {
        let service = MockHoroscopeService(latency: .instant)
        let date = DateComponents(year: 2026, month: 8, day: 11)

        let normal = try await service.generalReading(sign: sign, date: date, tone: .normal)
        let roast = try await service.generalReading(sign: sign, date: date, tone: .roast)

        #expect(normal.headline != roast.headline)
        for category in ReadingCategory.allCases {
            #expect(normal.text(for: category) != roast.text(for: category))
        }
    }
}

/// Shape, never truth.
///
/// Prevents "works for Pisces, crashes for Capricorn" without asserting that any
/// astrological value is correct — there is nothing to be correct against.
@MainActor
@Suite("Fixture completeness")
struct FixtureCompletenessTests {
    @Test("every sign has a complete reading in both registers", arguments: WesternSign.allCases)
    func everySignIsWritten(_ sign: WesternSign) async throws {
        let service = MockHoroscopeService(latency: .instant)
        for tone in Tone.allCases {
            let reading = try await service.generalReading(
                sign: sign,
                date: DateComponents(year: 2026, month: 8, day: 11),
                tone: tone
            )
            #expect(!reading.headline.isEmpty)
            #expect(!(reading.overview ?? "").isEmpty)
            #expect(!reading.basis.summary.isEmpty)
            for category in ReadingCategory.allCases {
                let text = reading.text(for: category) ?? ""
                #expect(!text.isEmpty, "\(sign.spokenName) \(tone.rawValue) \(category.rawValue) is empty")
            }
        }
    }

    @Test("the fixture bank covers all twelve signs")
    func allSignsPresent() {
        let covered = Set(DailyReadingFixtures.all.map(\.sign))
        #expect(covered.count == WesternSign.allCases.count)
    }

    @Test("every glossary term referenced by the chart resolves", arguments: ChartSystem.allCases)
    func glossaryResolves(_ system: ChartSystem) async throws {
        let chartService = MockChartCalculationService(latency: .instant)
        let glossary = MockGlossaryService(latency: .instant)
        let birth = BirthDetails(
            year: 1994,
            month: 3,
            day: 14,
            time: .exact(minutesFromMidnight: 462),
            place: .known(name: "Lisbon", latitude: 38.7, longitude: -9.1, timeZoneIdentifier: "Europe/Lisbon")
        )

        let chart = try await chartService.chart(for: birth, system: system)
        let triad: ChartTriad = switch chart {
        case .western(let c): c.triad
        case .vedic(let c): c.triad
        case .chinese(let c): c.triad
        }

        for entry in triad.entries {
            guard let termID = entry.glossaryTermID else { continue }
            let term = try await glossary.term(id: termID)
            // A term must belong to the system that presented it.
            #expect(term.system == system, "\(termID) is a \(term.system.shortName) term shown in \(system.shortName)")
        }
    }

    @Test("every placement in every system opens", arguments: ChartSystem.allCases)
    func placementsOpen(_ system: ChartSystem) async throws {
        let service = MockChartCalculationService(latency: .instant)
        let birth = BirthDetails(
            year: 1994,
            month: 3,
            day: 14,
            time: .exact(minutesFromMidnight: 462),
            place: .known(name: "Lisbon", latitude: 38.7, longitude: -9.1, timeZoneIdentifier: "Europe/Lisbon")
        )
        let chart = try await service.chart(for: birth, system: system)

        let identifiers: [String] = switch chart {
        case .western(let c): c.placements.map(\.id)
        case .vedic(let c): c.placements.map(\.id)
        case .chinese(let c): c.pillars.compactMap(\.value).map(\.id.rawValue)
        }

        #expect(!identifiers.isEmpty)
        for id in identifiers {
            let detail = try await service.placementDetail(id: id, in: chart)
            #expect(!detail.sections.isEmpty)
            #expect(detail.system == system)
        }
    }
}

/// Withholding, not guessing.
@MainActor
@Suite("Unknown birth data")
struct UnknownBirthDataTests {
    private let dateOnly = BirthDetails(year: 1994, month: 3, day: 14)

    @Test("a Western chart withholds rising and houses without a birth time")
    func westernWithholds() async throws {
        let chart = try await MockChartCalculationService(latency: .instant)
            .chart(for: dateOnly, system: .western)
        guard case .western(let western) = chart else { Issue.record("wrong system"); return }

        #expect(western.rising.unavailability == .requiresBirthTime)
        #expect(western.houses.unavailability == .requiresBirthTime)
        // The Sun survives — it does not depend on the time.
        #expect(western.sun.position.longitudeDegrees >= 0)
    }

    @Test("a Vedic chart withholds the lagna, nakshatra and dasha without a birth time")
    func vedicWithholds() async throws {
        let chart = try await MockChartCalculationService(latency: .instant)
            .chart(for: dateOnly, system: .vedic)
        guard case .vedic(let vedic) = chart else { Issue.record("wrong system"); return }

        #expect(vedic.lagna.unavailability == .requiresBirthTime)
        #expect(vedic.nakshatra.unavailability == .requiresBirthTime)
        #expect(vedic.currentDasha.unavailability == .requiresBirthTime)
    }

    @Test("a BaZi chart withholds the hour pillar without a birth time")
    func chineseWithholds() async throws {
        let chart = try await MockChartCalculationService(latency: .instant)
            .chart(for: dateOnly, system: .chinese)
        guard case .chinese(let chinese) = chart else { Issue.record("wrong system"); return }

        #expect(chinese.hourPillar.unavailability == .requiresBirthTime)
        // The year pillar follows from the date and is present.
        #expect(chinese.yearPillar.han.count == 2)
    }

    @Test("the BaZi luck cycle is withheld as methodology-pending, not as missing data")
    func luckCycleIsPending() async throws {
        let chart = try await MockChartCalculationService(latency: .instant)
            .chart(
                for: BirthDetails(
                    year: 1994, month: 3, day: 14,
                    time: .exact(minutesFromMidnight: 462),
                    place: .known(name: "Lisbon", latitude: 38.7, longitude: -9.1, timeZoneIdentifier: "Europe/Lisbon")
                ),
                system: .chinese
            )
        guard case .chinese(let chinese) = chart else { Issue.record("wrong system"); return }

        guard case .methodologyPending(let methodID) = chinese.luckCycle.unavailability else {
            Issue.record("Luck Cycle should be withheld pending methodology, not shown as decided")
            return
        }
        #expect(methodID == "METHOD-006")
    }
}
