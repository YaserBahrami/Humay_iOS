// ─────────────────────────────────────────────────────────────────────────────
//  MOCK CONTENT BOUNDARY — NOT A CALCULATION
//  Positions here come from MockAstrology, which is not astronomy. Prose is
//  illustrative. See docs/development/DEVIATIONS.md (DEV-001).
// ─────────────────────────────────────────────────────────────────────────────

import Foundation

/// Charts, built from fixtures.
///
/// Note how consistently the birth data gates the output: without a birth time, rising,
/// houses, the nakshatra, the lagna, the dasha and the hour pillar all come back
/// `.unavailable(.requiresBirthTime)` rather than being filled with something. That
/// behaviour is the part worth keeping when the real service arrives.
struct MockChartCalculationService: ChartCalculationService, MockContentProvider {
    static let fixtureNamespace = "chart"

    let latency: MockLatency

    init(latency: MockLatency = .realistic) {
        self.latency = latency
    }

    func signProfile(for birth: BirthDetails) async throws -> SignProfile {
        await latency.wait()
        let sun = MockAstrology.sunSign(for: birth)
        let rashi = MockAstrology.suryaRashi(for: birth)
        let pillar = MockAstrology.yearPillar(for: birth)

        return SignProfile(
            westernSun: sun,
            vedicSuryaRashi: rashi,
            chineseYearPillar: pillar,
            headline: SignProfileFixtures.headline(for: sun),
            body: SignProfileFixtures.body(for: sun),
            basisNote: "Everything here follows from your birth date. Moon, Rising, houses, bhavas and the hour pillar need a birth time and place.",
            provenance: Self.provenance("signProfile.\(sun.rawValue)")
        )
    }

    func chart(for birth: BirthDetails, system: ChartSystem) async throws -> SystemChart {
        await latency.wait()
        switch system {
        case .western: return .western(westernChart(for: birth))
        case .vedic: return .vedic(vedicChart(for: birth))
        case .chinese: return .chinese(chineseChart(for: birth))
        }
    }

    func placementDetail(id: String, in chart: SystemChart) async throws -> PlacementDetail {
        await latency.wait()
        switch chart {
        case .western(let western):
            guard let placement = western.placements.first(where: { $0.id == id }) else {
                throw HumayServiceError.contentUnavailable(id)
            }
            return PlacementDetailFixtures.detail(for: placement, in: western, provenance: Self.provenance("placement.\(id)"))
        case .vedic(let vedic):
            guard let placement = vedic.placements.first(where: { $0.id == id }) else {
                throw HumayServiceError.contentUnavailable(id)
            }
            return PlacementDetailFixtures.detail(for: placement, in: vedic, provenance: Self.provenance("placement.\(id)"))
        case .chinese(let chinese):
            guard let pillar = chinese.pillars.compactMap(\.value).first(where: { $0.id.rawValue == id }) else {
                throw HumayServiceError.contentUnavailable(id)
            }
            return PlacementDetailFixtures.detail(for: pillar, in: chinese, provenance: Self.provenance("placement.\(id)"))
        }
    }

    // MARK: - Western

    private func westernChart(for birth: BirthDetails) -> WesternChart {
        let timeKnown = birth.time.isKnown
        let placeKnown = birth.place.isKnown

        let placements = Planet.allCases.map { planet in
            PlanetPlacement(
                planet: planet,
                position: MockAstrology.longitude(for: planet, birth: birth),
                house: houseValue(for: planet, birth: birth, timeKnown: timeKnown, placeKnown: placeKnown),
                isRetrograde: [Planet.saturn, .neptune, .pluto].contains(planet),
                meaning: WesternChartFixtures.placementMeaning(for: planet)
            )
        }

        let sun = placements.first { $0.planet == .sun } ?? placements[0]
        let moonPlacement = placements.first { $0.planet == .moon } ?? placements[0]

        // The Moon's sign usually survives an unknown birth time; its degree does not.
        let moon: FactValue<PlanetPlacement> = timeKnown
            ? .available(moonPlacement)
            : .uncertain(moonPlacement, window: "Degree uncertain without a birth time")

        let rising: FactValue<PlanetPlacement>
        if timeKnown && placeKnown {
            rising = .available(
                PlanetPlacement(
                    planet: .sun,
                    position: MockAstrology.longitude(for: .venus, birth: birth),
                    house: .available(1),
                    isRetrograde: false,
                    meaning: "The sign rising on the eastern horizon at the moment you were born. It sets the houses for the rest of the chart."
                )
            )
        } else {
            rising = .unavailable(reason: timeKnown ? .requiresBirthPlace : .requiresBirthTime)
        }

        let houses: FactValue<[House]>
        if timeKnown && placeKnown {
            houses = .available(WesternChartFixtures.houses(anchoredAt: MockAstrology.longitude(for: .venus, birth: birth)))
        } else {
            houses = .unavailable(reason: timeKnown ? .requiresBirthPlace : .requiresBirthTime)
        }

        return WesternChart(
            sun: sun,
            moon: moon,
            rising: rising,
            placements: placements,
            houses: houses,
            aspects: WesternChartFixtures.aspects(for: placements),
            headline: WesternChartFixtures.headline(for: sun.position.sign, hasRising: rising.isAvailable),
            feature: WesternChartFixtures.feature(for: sun.position.sign),
            provenance: Self.provenance("western.\(sun.position.sign.rawValue)")
        )
    }

    private func houseValue(
        for planet: Planet,
        birth: BirthDetails,
        timeKnown: Bool,
        placeKnown: Bool
    ) -> FactValue<Int> {
        guard timeKnown else { return .unavailable(reason: .requiresBirthTime) }
        guard placeKnown else { return .unavailable(reason: .requiresBirthPlace) }
        let index = Planet.allCases.firstIndex(of: planet) ?? 0
        return .available((index * 3 + birth.day) % 12 + 1)
    }

    // MARK: - Vedic

    private func vedicChart(for birth: BirthDetails) -> VedicChart {
        let timeKnown = birth.time.isKnown
        let placeKnown = birth.place.isKnown
        let surya = MockAstrology.suryaRashi(for: birth)
        let chandra = MockAstrology.chandraRashi(for: birth)

        let placements = Graha.allCases.enumerated().map { index, graha in
            GrahaPlacement(
                graha: graha,
                rashi: Rashi.allCases[(index * 5 + birth.day) % 12],
                degreeInRashi: timeKnown
                    ? .available(Double((index * 7 + birth.day) % 30) + 0.4)
                    : .uncertain(Double((index * 7 + birth.day) % 30), window: "Approximate without a birth time"),
                bhava: timeKnown && placeKnown
                    ? .available((index * 2 + birth.month) % 12 + 1)
                    : .unavailable(reason: timeKnown ? .requiresBirthPlace : .requiresBirthTime),
                nakshatra: timeKnown
                    ? .available(Nakshatra.allCases[(index * 3 + birth.day) % 27])
                    : .unavailable(reason: .requiresBirthTime),
                meaning: VedicChartFixtures.placementMeaning(for: graha)
            )
        }

        return VedicChart(
            suryaRashi: surya,
            chandraRashi: chandra,
            lagna: timeKnown && placeKnown
                ? .available(Rashi.allCases[(birth.day + birth.year) % 12])
                : .unavailable(reason: timeKnown ? .requiresBirthPlace : .requiresBirthTime),
            nakshatra: timeKnown
                ? .available(Nakshatra.allCases[(birth.day * 2) % 27])
                : .unavailable(reason: .requiresBirthTime),
            placements: placements,
            bhavas: timeKnown && placeKnown
                ? .available(VedicChartFixtures.bhavas)
                : .unavailable(reason: timeKnown ? .requiresBirthPlace : .requiresBirthTime),
            currentDasha: timeKnown
                ? .available(VedicChartFixtures.dasha(seed: birth.day))
                : .unavailable(reason: .requiresBirthTime),
            ayanamsaNote: "Shown against the Lahiri ayanamsa, which is a development default and not a signed-off methodology choice.",
            headline: VedicChartFixtures.headline(for: chandra, hasLagna: timeKnown && placeKnown),
            feature: VedicChartFixtures.feature(hasDasha: timeKnown),
            provenance: Self.provenance("vedic.\(chandra.rawValue)")
        )
    }

    // MARK: - Chinese

    private func chineseChart(for birth: BirthDetails) -> ChineseChart {
        let year = MockAstrology.yearPillar(for: birth)
        let month = MockAstrology.monthPillar(for: birth)
        let day = MockAstrology.dayPillar(for: birth)
        let hour = MockAstrology.hourPillar(for: birth)

        var balance: [WuXing: Int] = [:]
        for element in WuXing.allCases { balance[element] = 0 }
        for pillar in [year, month, day] {
            balance[pillar.element, default: 0] += 1
        }
        if let hour { balance[hour.element, default: 0] += 1 }

        return ChineseChart(
            yearPillar: year,
            monthPillar: .available(month),
            dayPillar: .available(day),
            hourPillar: hour.map { FactValue.available($0) } ?? .unavailable(reason: .requiresBirthTime),
            dayMaster: .available(
                DayMaster(
                    stem: day.stem,
                    summary: ChineseChartFixtures.dayMasterSummary(for: day.stem.element)
                )
            ),
            elementBalance: balance,
            // The direction the Luck Cycle runs depends on a convention that has not
            // been decided, so it is withheld rather than shown as settled.
            luckCycle: .unavailable(reason: .methodologyPending(methodID: "METHOD-006")),
            calendarNote: "Pillars shown against the calendar year. A real chart uses solar terms for the month boundary and a defined day boundary — both still to be settled.",
            headline: ChineseChartFixtures.headline(for: day.stem.element, hasHour: hour != nil),
            feature: ChineseChartFixtures.feature(for: day.stem.element),
            provenance: Self.provenance("chinese.\(day.stem.rawValue)")
        )
    }
}
