import Foundation
import Testing
@testable import Humay

@Suite("Humay content engine")
struct ContentEngineTests {
    private let profile = UserProfile(
        id: UUID(uuidString: "77777777-7777-4777-8777-777777777777")!,
        displayName: "Yaser",
        birth: BirthDetails(year: 1993, month: 8, day: 7)
    )

    private var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        return calendar
    }

    private var referenceDate: Date {
        calendar.date(from: DateComponents(year: 2026, month: 8, day: 26))!
    }

    @Test("Daily feed is deterministic for the same profile and day")
    func dailyFeedIsDeterministic() {
        let first = HumayContentEngine.dailyFeed(
            profile: profile,
            date: referenceDate,
            calendar: calendar,
            mode: .normal,
            skyEvent: nil
        )
        let second = HumayContentEngine.dailyFeed(
            profile: profile,
            date: referenceDate,
            calendar: calendar,
            mode: .normal,
            skyEvent: nil
        )

        #expect(first == second)
        #expect(!first.isEmpty)
    }

    @Test("Feed always opens with a headline and contains meters")
    func feedCompositionHasCoreSections() {
        let items = HumayContentEngine.dailyFeed(
            profile: profile,
            date: referenceDate,
            calendar: calendar,
            mode: .bestie,
            skyEvent: nil
        )

        guard case .headline = items.first?.kind else {
            Issue.record("Feed must open with a headline item")
            return
        }
        #expect(items.contains { item in
            if case .meterSet = item.kind { return true }
            return false
        })
        #expect(items.contains { item in
            if case .roast = item.kind { return true }
            return false
        })
    }

    @Test("Personality mode changes expression without changing structure guarantees")
    func personalityModeChangesExpression() {
        let normal = HumayContentEngine.dailyFeed(
            profile: profile,
            date: referenceDate,
            calendar: calendar,
            mode: .normal,
            skyEvent: nil
        )
        let roast = HumayContentEngine.dailyFeed(
            profile: profile,
            date: referenceDate,
            calendar: calendar,
            mode: .roast,
            skyEvent: nil
        )

        #expect(normal != roast)

        for pair in zip(normal, roast) {
            switch (pair.0.kind, pair.1.kind) {
            case (.headline(let a), .headline(let b)):
                #expect(a.kicker == b.kicker)
            default:
                continue
            }
        }
    }

    @Test("Cosmic weather preserves the fact line verbatim")
    func cosmicWeatherKeepsFactSeparate() {
        let seed = CosmicEventSeed(
            id: "venus-ingress-1",
            humanHeadline: "Venus changed the vibe.",
            factLine: "Venus enters Libra at 18:32."
        )
        let items = HumayContentEngine.dailyFeed(
            profile: profile,
            date: referenceDate,
            calendar: calendar,
            mode: .normal,
            skyEvent: seed
        )

        let weather = items.first { item in
            if case .cosmicWeather = item.kind { return true }
            return false
        }
        guard case .cosmicWeather(let content)? = weather?.kind else {
            Issue.record("Expected a cosmic weather item")
            return
        }
        #expect(content.factLine == "Venus enters Libra at 18:32.")
        #expect(content.skyEventID == "venus-ingress-1")
    }

    @Test("Archetype assignment is stable per profile")
    func archetypeAssignmentIsStable() {
        let first = HumayContentEngine.archetype(profileID: profile.id)
        let second = HumayContentEngine.archetype(profileID: profile.id)

        #expect(first == second)
        #expect(HumayArchetype.catalog.contains(first))
    }

    @Test("Compatibility verdicts are bounded and deterministic")
    func compatibilityVerdictInvariants() {
        let salma = ConnectionPerson(
            id: UUID(uuidString: "22222222-2222-4222-8222-222222222222")!,
            name: "Salma",
            relationshipKind: .crush,
            birth: BirthDetails(year: 1995, month: 6, day: 3)
        )
        let mahtab = ConnectionPerson(
            id: UUID(uuidString: "33333333-3333-4333-8333-333333333333")!,
            name: "Mahtab",
            relationshipKind: .friend,
            birth: BirthDetails(year: 1994, month: 11, day: 21)
        )

        let first = HumayContentEngine.compatibility(first: salma, second: mahtab, mode: .normal)
        let second = HumayContentEngine.compatibility(first: salma, second: mahtab, mode: .drama)

        // Mode must not change the underlying result.
        #expect(first == second)
        #expect((38...97).contains(first.overall))
        #expect(first.funMetrics.allSatisfy { (0...100).contains($0.value) })
        #expect(!first.verdictLines.isEmpty)
        #expect(!first.astrologyBasis.isEmpty)
        #expect(first.headline.isEmpty == false)
    }
}

@Suite("Yearly forecast")
struct YearlyForecastTests {
    private let profileID = UUID(uuidString: "77777777-7777-4777-8777-777777777777")!

    @Test("Forecast has a full year of valid scores with provenance")
    func forecastShapeIsValid() {
        let forecast = HumayContentEngine.yearlyForecast(
            profileID: profileID,
            birth: BirthDetails(year: 1993, month: 8, day: 7)
        )

        #expect(forecast.days.count == YearlyForecast.dayCount)
        #expect(forecast.provenance.isCompatibleWith(currentGeneratorVersion: YearlyForecast.currentGeneratorVersion))
        #expect(forecast.provenance.basis == .entertainmentFixture)
        #expect(!forecast.provenance.basis.isPersonalizedAI)

        for day in forecast.days.prefix(50) {
            for dimension in MoodDimension.allCases {
                #expect((0...100).contains(day.scores[dimension]))
            }
        }
    }

    @Test("Forecast is deterministic per profile")
    func forecastIsDeterministic() {
        let first = HumayContentEngine.yearlyForecast(
            profileID: profileID,
            birth: BirthDetails(year: 1993, month: 8, day: 7)
        )
        let second = HumayContentEngine.yearlyForecast(
            profileID: profileID,
            birth: BirthDetails(year: 1993, month: 8, day: 7)
        )
        let otherProfile = HumayContentEngine.yearlyForecast(
            profileID: UUID(),
            birth: BirthDetails(year: 1993, month: 8, day: 7)
        )

        // Provenance carries a generation timestamp; the content itself must be
        // identical for identical inputs.
        #expect(first.days == second.days)
        #expect(first.days != otherProfile.days)
    }

    @Test("Anchor converts offsets to dates and back within the rolling year")
    func anchorRoundTripsOffsets() {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        let anchor = ForecastAnchor(date: calendar.date(from: DateComponents(year: 2026, month: 8, day: 26))!, calendar: calendar)

        let date = anchor.date(forDayOffset: 30, calendar: calendar)
        #expect(date != nil)
        #expect(anchor.dayOffset(for: date!, calendar: calendar) == 30)

        let januaryOffsets = anchor.dayOffsets(inMonthIndex: 4, totalDays: YearlyForecast.dayCount, calendar: calendar)
        #expect(!januaryOffsets.isEmpty)
    }

    @Test("Top and bottom day lookups stay inside the dataset")
    func extremeLookupsStayBounded() {
        let forecast = HumayContentEngine.yearlyForecast(
            profileID: profileID,
            birth: BirthDetails(year: 1993, month: 8, day: 7)
        )

        let best = forecast.topDays(in: .overall, count: 3)
        let worst = forecast.bottomDays(in: .overall, count: 3)

        #expect(best.count == 3)
        #expect(worst.count == 3)
        #expect(best[0].scores[.overall] >= best[2].scores[.overall])
        #expect(worst[0].scores[.overall] <= worst[2].scores[.overall])
    }
}

@Suite("Connections and sun sign calendar")
struct ConnectionModelTests {
    @Test("Sun sign table covers every civil date")
    func sunSignTableIsTotal() {
        #expect(SunSignCalendar.westernSunSign(month: 8, day: 7) == .leo)
        #expect(SunSignCalendar.westernSunSign(month: 12, day: 25) == .capricorn)
        #expect(SunSignCalendar.westernSunSign(month: 1, day: 5) == .capricorn)
        #expect(SunSignCalendar.westernSunSign(month: 3, day: 21) == .aries)
        #expect(SunSignCalendar.westernSunSign(month: 9, day: 23) == .libra)

        // Every legal day resolves.
        for month in 1...12 {
            let days = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31][month - 1]
            for day in 1...days {
                #expect(SunSignCalendar.westernSunSign(month: month, day: day) != nil)
            }
        }

        #expect(SunSignCalendar.westernSunSign(month: 13, day: 1) == nil)
    }

    @Test("Connection derives its sign from the birth date")
    func connectionDerivesSign() {
        let person = ConnectionPerson(
            name: "Salma",
            relationshipKind: .crush,
            birth: BirthDetails(year: 1995, month: 6, day: 3)
        )

        #expect(person.westernSunSign == .gemini)
        #expect(person.initials == "S")
        #expect(person.displayLabel == "Crush")
    }

    @Test("Custom labels surface only for custom relationships")
    func customLabelsRespectKind() {
        let custom = ConnectionPerson(
            name: "Mystery",
            relationshipKind: .custom,
            customLabel: "Gym nemesis",
            birth: BirthDetails(year: 1990, month: 2, day: 2)
        )

        #expect(custom.displayLabel == "Gym nemesis")

        let plain = ConnectionPerson(
            name: "Plain",
            relationshipKind: .friend,
            customLabel: "Ignored",
            birth: BirthDetails(year: 1990, month: 2, day: 2)
        )

        #expect(plain.displayLabel == "Friend")
    }
}
