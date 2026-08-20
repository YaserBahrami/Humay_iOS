import Foundation
import Testing
@testable import Humay

@Suite("D2 feature contracts")
struct D2FeatureModelTests {
    @Test("Daily periods preserve approved order")
    func dailyPeriodsPreserveOrder() {
        #expect(HoroscopePeriod.allCases == [.today, .tomorrow, .thisWeek])
    }

    @Test("Free and precise daily bases cannot be confused")
    func dailyBasisSeparation() {
        let free = DailyReadingBasis.freeWesternSunSign(.leo)
        let precise = DailyReadingBasis.precisePersonalized

        #expect(!free.isPrecise)
        #expect(precise.isPrecise)
        #expect(free != precise)
    }

    @Test("Western Free compatibility has 144 ordered catalog keys")
    func freeCompatibilityCatalogCardinality() {
        let keys = WesternSunSignPairKey.allCatalogKeys

        #expect(keys.count == 144)
        #expect(Set(keys).count == 144)
        #expect(keys.contains(WesternSunSignPairKey(first: .leo, second: .gemini)))
        #expect(keys.contains(WesternSunSignPairKey(first: .gemini, second: .leo)))
    }

    @Test("Compatibility scores enforce zero through one hundred")
    func compatibilityScoreRange() {
        #expect(CompatibilityScore(0)?.value == 0)
        #expect(CompatibilityScore(81)?.value == 81)
        #expect(CompatibilityScore(100)?.value == 100)
        #expect(CompatibilityScore(-1) == nil)
        #expect(CompatibilityScore(101) == nil)
    }

    @Test("Compatibility selection starts with the first two people in stable order")
    func compatibilitySelectionInitialPairIsDeterministic() {
        let people = compatibilitySelectionPeople
        let selection = CompatibilityPairSelection(people: people)

        #expect(selection.selectedIDs == [people[0].id, people[1].id])
        #expect(selection.isComplete)
    }

    @Test("Compatibility selection caps at two and supports deselection")
    func compatibilitySelectionCapsAndDeselects() {
        let people = compatibilitySelectionPeople
        var selection = CompatibilityPairSelection(people: people)

        selection.toggle(people[2].id)
        #expect(selection.selectedIDs == [people[0].id, people[1].id])

        selection.toggle(people[0].id)
        #expect(selection.selectedIDs == [people[1].id])
        #expect(!selection.isComplete)

        selection.toggle(people[2].id)
        #expect(selection.selectedIDs == [people[1].id, people[2].id])
        #expect(selection.isComplete)

        selection.toggle(people[1].id)
        #expect(selection.selectedIDs == [people[2].id])
    }

    @Test("New person keeps unknown precision explicit")
    func personUnknownPrecision() {
        let person = CirclePerson(
            name: "New Person",
            birth: BirthDetails(year: 1994, month: 3, day: 14)
        )

        #expect(person.birth.time == .unknown)
        #expect(person.birth.place == .notProvided)
        #expect(person.westernSunSign == nil)
        #expect(!person.birth.supportsPrecision)
    }

    @Test("Release composition contains no development previews")
    func releaseCompositionContainsNoDevelopmentPreviews() {
        let input = D2FeatureInput.productionUnavailable

        #expect(input.source == .productionUnavailable)
        #expect(!input.source.isDevelopmentSample)
        #expect(input.preciseDailyPreview == nil)
        #expect(input.preciseCompatibilityPreview == nil)
        #expect(input.circle == .empty)
        for period in HoroscopePeriod.allCases {
            guard case .failed(let failedPeriod, _) = input.dailyState(for: period) else {
                Issue.record("Release daily state must be explicitly unavailable")
                continue
            }
            #expect(failedPeriod == period)
        }
    }

#if DEBUG
    @Test("Development composition has complete typed content")
    func developmentCompositionIsComplete() throws {
        let input = DevelopmentD2Sample.makeInput(arguments: [])
        let today = try #require(DevelopmentD2Sample.freeReadings[.today])

        #expect(input.source == .developmentSample)
        #expect(today.basis == .freeWesternSunSign(.leo))
        #expect(today.hasCompleteCategorySet)
        #expect(DevelopmentD2Sample.preciseDailyReading.basis == .precisePersonalized)
        #expect(DevelopmentD2Sample.freeCompatibility.catalogKey == .init(first: .leo, second: .gemini))
        #expect(DevelopmentD2Sample.freeCompatibility.hasCompleteMetricSet)
        #expect(DevelopmentD2Sample.preciseCompatibility.hasCompleteMetricSet)
        #expect(input.preciseDailyPreview != nil)
        #expect(input.preciseCompatibilityPreview != nil)
    }

    @Test("Development launch arguments expose explicit state variants")
    func developmentStateVariants() {
        let input = DevelopmentD2Sample.makeInput(arguments: [
            "-HumayD2TodayState", "offline",
            "-HumayD2DailyState", "cached",
            "-HumayD2CircleState", "empty",
            "-HumayD2CompatibilityState", "locked"
        ])

        guard case .offline(let cachedToday) = input.today else {
            Issue.record("Expected Today offline state")
            return
        }
        #expect(cachedToday != nil)

        guard case .cached = input.dailyState(for: .today) else {
            Issue.record("Expected cached daily state")
            return
        }
        #expect(input.circle == .empty)

        guard case .preciseLocked = input.compatibility else {
            Issue.record("Expected precise compatibility locked state")
            return
        }

        let noCache = DevelopmentD2Sample.makeInput(arguments: [
            "-HumayD2DailyState", "offline-empty",
            "-HumayD2CircleState", "offline-empty"
        ])

        guard case .offline(let dailyCache) = noCache.dailyState(for: .today) else {
            Issue.record("Expected Daily Horoscope offline state")
            return
        }
        #expect(dailyCache == nil)

        guard case .offline(let peopleCache) = noCache.circle else {
            Issue.record("Expected Connections offline state")
            return
        }
        #expect(peopleCache.isEmpty)
    }
#endif

    private var compatibilitySelectionPeople: [CirclePerson] {
        [
            CirclePerson(
                id: UUID(uuidString: "AAAAAAAA-AAAA-4AAA-8AAA-AAAAAAAAAAAA")!,
                name: "Alexandria",
                birth: BirthDetails(year: 1990, month: 12, day: 2),
                westernSunSign: .sagittarius
            ),
            CirclePerson(
                id: UUID(uuidString: "BBBBBBBB-BBBB-4BBB-8BBB-BBBBBBBBBBBB")!,
                name: "Christopher",
                birth: BirthDetails(year: 1991, month: 1, day: 4),
                westernSunSign: .capricorn
            ),
            CirclePerson(
                id: UUID(uuidString: "CCCCCCCC-CCCC-4CCC-8CCC-CCCCCCCCCCCC")!,
                name: "Salma",
                birth: BirthDetails(year: 1995, month: 6, day: 3),
                westernSunSign: .gemini
            )
        ]
    }
}
