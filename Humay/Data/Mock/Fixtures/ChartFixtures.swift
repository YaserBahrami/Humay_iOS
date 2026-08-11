// ─────────────────────────────────────────────────────────────────────────────
//  MOCK CONTENT BOUNDARY — NOT A CALCULATION
//  Illustrative sample content. Not ephemeris output. Not a test oracle.
// ─────────────────────────────────────────────────────────────────────────────

import Foundation

enum SignProfileFixtures {
    static func headline(for sign: WesternSign) -> String {
        headlines[sign] ?? "A \(sign.spokenName) sun."
    }

    static func body(for sign: WesternSign) -> String {
        bodies[sign] ?? "The Sun's sign says something about how you operate. It is one factor among many, and on its own it describes a great many people at once."
    }

    private static let headlines: [WesternSign: String] = [
        .aries: "An Aries sun, deciding before the room has finished asking.",
        .taurus: "A Taurus sun, unhurried in a way that reads as certainty.",
        .gemini: "A Gemini sun, already three questions ahead.",
        .cancer: "A Cancer sun, keeping the room warm from just outside it.",
        .leo: "A Leo sun, generous first and counting later.",
        .virgo: "A Virgo sun, noticing the thing everyone walked past.",
        .libra: "A Libra sun, weighing the room before entering it.",
        .scorpio: "A Scorpio sun, watching longer than anyone realises.",
        .sagittarius: "A Sagittarius sun, halfway out the door and enjoying it.",
        .capricorn: "A Capricorn sun, carrying more than was ever assigned.",
        .aquarius: "An Aquarius sun, standing one step outside the frame.",
        .pisces: "A Pisces sun, reading the room before it speaks.",
    ]

    private static let bodies: [WesternSign: String] = [
        .aries: "Directness is the default, and the pause before it is the learned part. What reads as impatience is usually a low tolerance for pretending the decision has not already been made.",
        .taurus: "Slowness here is not hesitation, it is a refusal to be hurried into something that will have to be undone. The cost is that genuine stuckness looks identical from the outside.",
        .gemini: "Curiosity arrives faster than conclusions, which is a real advantage until a decision is needed. Range is the strength; returning to finish is the discipline.",
        .cancer: "Attention runs outward by reflex. The care is real and so is the habit of using other people's needs as somewhere to put your own.",
        .leo: "Warmth given first, without waiting to see whether it will be returned. The vulnerable part is how much of the reading of a quiet room is taken personally.",
        .virgo: "Precision applied as a form of care rather than criticism, though the two are easily confused from outside. The standard is usually harshest when turned inward.",
        .libra: "Balance held so consistently that a stated preference feels almost rude. The strength is genuine fairness; the cost is a decision deferred until it is made for you.",
        .scorpio: "Depth over breadth, and a habit of knowing more than has been said. Trust is slow because it is taken seriously, not because it is withheld for sport.",
        .sagittarius: "Momentum toward the next thing, and real conviction while in it. Beginning is effortless; the discipline is in staying long enough for it to become something.",
        .capricorn: "Responsibility taken up quietly, often before anyone asks. The competence is real and it is also a very effective way of never needing anyone.",
        .aquarius: "Perspective from slightly outside, which is genuinely useful and occasionally a way of not being present. Ideas arrive well ahead of the willingness to be in the room for them.",
        .pisces: "Attunement runs high — moods are picked up before they are announced. The gift and the cost are the same: it is hard to tell whose feeling arrived first.",
    ]
}

enum WesternChartFixtures {
    static func headline(for sign: WesternSign, hasRising: Bool) -> String {
        hasRising
            ? "A peacemaking door over a sprinter's pulse."
            : "A \(sign.spokenName) sun, with the door still to be described."
    }

    static func feature(for sign: WesternSign) -> ChartFeature {
        ChartFeature(
            kicker: "The strongest thing in your chart",
            headline: "Your Mars sits eight arcminutes from Saturn — wanting and holding back, fused.",
            body: "Mars and Saturn share almost the same degree. Drive and restraint do not arrive as two separate moves for you; they arrive as one reflex, which is why acting on impulse and acting with discipline can look identical from the outside — and why both can feel equally like effort."
        )
    }

    static func placementMeaning(for planet: Planet) -> String {
        meanings[planet] ?? "What this body is doing in your chart."
    }

    private static let meanings: [Planet: String] = [
        .sun: "The centre of the chart — what you are organised around, and what you return to when nothing is demanding otherwise.",
        .moon: "The reflex underneath the presentation. How you settle, what settles you, and what you reach for without deciding to.",
        .mercury: "How thinking becomes speech. The pace of it, and whether you work things out before saying them or by saying them.",
        .venus: "What you find beautiful and how you show it. Also how you value things, which is the less romantic half of the same question.",
        .mars: "How you want, and what you do about wanting. Where the friction goes when it does not go outward.",
        .jupiter: "Where you expect more than is reasonable, and are often right. The place you are generous without noticing.",
        .saturn: "The place that asks for time. Not a punishment — a bill for the thing that will hold weight later.",
        .uranus: "The break in the pattern. Where you cannot be talked into the ordinary version.",
        .neptune: "The blur. Where the boundary between you and the situation is genuinely hard to find.",
        .pluto: "The long pressure. What is being rebuilt slowly enough that you only notice afterwards.",
    ]

    static func houses(anchoredAt ascendant: Ecliptic) -> [House] {
        (1...12).map { index in
            House(
                id: index,
                cusp: Ecliptic(longitudeDegrees: ascendant.longitudeDegrees + Double(index - 1) * 30),
                title: houseTitles[index - 1],
                summary: houseSummaries[index - 1]
            )
        }
    }

    private static let houseTitles = [
        "Self and approach", "Resources and worth", "Speech and near ones", "Home and origins",
        "Play and expression", "Work and routine", "Partnership", "What is shared",
        "Belief and distance", "Standing and vocation", "Community and hopes", "The interior",
    ]

    private static let houseSummaries = [
        "The door you present at, before anyone has heard you speak.",
        "What you own and what you consider yourself worth. Often the same conversation.",
        "Everyday exchange — siblings, neighbours, the short journeys.",
        "Where you are from and where you retreat to. Not always the same address.",
        "What you make for the pleasure of making it.",
        "The daily work, and the body that does it.",
        "The one you meet as an equal, which is why it is difficult.",
        "Trust, exposure, and what is not divided evenly.",
        "What you believe when nobody is checking.",
        "What you are known for, whether or not you chose it.",
        "The people you are among rather than paired with.",
        "What runs underneath, and takes solitude to hear.",
    ]

    static func aspects(for placements: [PlanetPlacement]) -> [Aspect] {
        var results: [Aspect] = []
        for (index, first) in placements.enumerated() {
            for second in placements.dropFirst(index + 1) {
                let separation = angularSeparation(
                    first.position.longitudeDegrees,
                    second.position.longitudeDegrees
                )
                for kind in AspectKind.allCases {
                    let orb = abs(separation - kind.exactAngle)
                    // A generous fixed orb. A real implementation varies it by body and
                    // by aspect, which is one of the open methodology questions.
                    guard orb <= 6 else { continue }
                    results.append(
                        Aspect(
                            first: first.planet,
                            second: second.planet,
                            kind: kind,
                            orbDegrees: orb,
                            meaning: aspectMeaning(kind)
                        )
                    )
                }
            }
        }
        return results.sorted { $0.orbDegrees < $1.orbDegrees }
    }

    private static func angularSeparation(_ first: Double, _ second: Double) -> Double {
        let raw = abs(first - second).truncatingRemainder(dividingBy: 360)
        return raw > 180 ? 360 - raw : raw
    }

    private static func aspectMeaning(_ kind: AspectKind) -> String {
        switch kind {
        case .conjunction: "Fused. These two do not arrive separately for you."
        case .sextile: "Available to each other, but only when asked."
        case .square: "Friction that produces something. It does not resolve; it works."
        case .trine: "Easy enough that it is often taken for granted."
        case .opposition: "Held at either end. The work is not choosing one."
        }
    }
}

enum VedicChartFixtures {
    static func headline(for rashi: Rashi, hasLagna: Bool) -> String {
        hasLagna
            ? "A steady house, unsettled by an old debt."
            : "Chandra in \(rashi.spokenName), with the Lagna still to be found."
    }

    static func feature(hasDasha: Bool) -> ChartFeature {
        hasDasha
            ? ChartFeature(
                kicker: "Your current dasha period",
                headline: "You have been in your Shukra Mahadasha since your mid-thirties.",
                body: "Vedic timing does not read the moving sky against your chart the way transits do. It runs a sequence of periods, each governed by a graha, and the chapter you are in colours everything else. Shukra tends to steady resources and slow romantic timing — which reads as stability or as stalling depending on what you wanted from the decade."
            )
            : ChartFeature(
                kicker: "Your dasha period",
                headline: "Dasha timing needs a birth time.",
                body: "The Vimshottari sequence is anchored to the Moon's exact position at birth, so its start dates cannot be recovered from a date alone. This is withheld rather than estimated — a dasha with the wrong start date is worse than no dasha at all."
            )
    }

    static func placementMeaning(for graha: Graha) -> String {
        meanings[graha] ?? "What this graha carries in your chart."
    }

    private static let meanings: [Graha: String] = [
        .surya: "Surya — the self as it is held in public, and the relationship to authority, including your own.",
        .chandra: "Chandra — the mind and its weather. Vedic astrology reads this first, before the Sun.",
        .budha: "Budha — speech, discrimination, and the ability to divide one thing from another.",
        .shukra: "Shukra — pleasure, refinement, and what you are willing to be devoted to.",
        .mangala: "Mangala — capacity for effort and for conflict. The willingness to meet resistance directly.",
        .guru: "Guru — expansion, teaching, and what you are given more of than you asked for.",
        .shani: "Shani — duration. What is earned slowly and therefore holds.",
        .rahu: "Rahu — the appetite that does not know when it is full. Where you push past what is comfortable.",
        .ketu: "Ketu — the place you have already been. Detachment that can read as mastery or as absence.",
    ]

    static let bhavas: [Bhava] = [
        Bhava(id: 1, title: "Tanu", summary: "The body and the self as it is met."),
        Bhava(id: 2, title: "Dhana", summary: "Held wealth, family, and speech."),
        Bhava(id: 3, title: "Sahaja", summary: "Effort, siblings, and courage of the everyday kind."),
        Bhava(id: 4, title: "Sukha", summary: "Comfort, mother, home, and inner ease."),
        Bhava(id: 5, title: "Putra", summary: "Intelligence, creation, and merit carried forward."),
        Bhava(id: 6, title: "Ari", summary: "Debt, illness, and the obstacles that sharpen."),
        Bhava(id: 7, title: "Yuvati", summary: "Partnership and open dealings."),
        Bhava(id: 8, title: "Randhra", summary: "What is hidden, inherited, and transformed."),
        Bhava(id: 9, title: "Dharma", summary: "Fortune, teachers, and what you hold to be right."),
        Bhava(id: 10, title: "Karma", summary: "Action in the world, and standing."),
        Bhava(id: 11, title: "Labha", summary: "Gains, networks, and what arrives through others."),
        Bhava(id: 12, title: "Vyaya", summary: "Loss, release, and what is spent in private."),
    ]

    static func dasha(seed: Int) -> DashaPeriod {
        let lord = Graha.allCases[seed % Graha.allCases.count]
        return DashaPeriod(
            lord: lord,
            level: .maha,
            startedAtAge: 20 + seed % 15,
            endsAtAge: 40 + seed % 15,
            summary: "A \(lord.spokenName) period colours the chapter rather than the day. It sets what the years are about, and the sky moving overhead is read against it."
        )
    }
}

enum ChineseChartFixtures {
    static func headline(for element: WuXing, hasHour: Bool) -> String {
        hasHour
            ? "A \(element.spokenName) Day Master, steadied by what surrounds it."
            : "A \(element.spokenName) Day Master, with the hour pillar still missing."
    }

    static func feature(for element: WuXing) -> ChartFeature {
        ChartFeature(
            kicker: "Your Day Master",
            headline: "\(element.spokenName), read against the company it keeps.",
            body: dayMasterSummary(for: element)
        )
    }

    static func dayMasterSummary(for element: WuXing) -> String {
        switch element {
        case .wood:
            "Wood grows toward something, and needs both room and resistance. Supported by Water it keeps going; met with too much Metal it is cut back before it has height."
        case .fire:
            "Fire is visible and does not last on its own. It needs Wood to feed it and something to be for; without either it burns brightly for a short while and then asks why it is tired."
        case .earth:
            "Earth holds things and is slow to move. It is what others build on, which is a real strength and also how it ends up carrying more than it agreed to."
        case .metal:
            "Metal separates and refines. It is precise and it cuts, and the same edge that makes it useful is what makes it hard to be soft with."
        case .water:
            "Water finds the way around rather than through. Adaptable to the point of formlessness, so what it needs most is a channel — something to run along."
        }
    }
}

enum PlacementDetailFixtures {
    static func detail(
        for placement: PlanetPlacement,
        in chart: WesternChart,
        provenance: ContentProvenance
    ) -> PlacementDetail {
        let related = chart.aspects.filter { $0.first == placement.planet || $0.second == placement.planet }

        var sections: [PlacementDetail.Section] = [
            .init(id: "meaning", title: "Meaning", body: placement.meaning, facts: [])
        ]

        sections.append(
            .init(
                id: "aspects",
                title: "Aspects",
                body: related.isEmpty
                    ? "Nothing in the chart is close enough to this to count as an aspect. That is not an absence of meaning — an unaspected body simply acts on its own terms."
                    : "How this connects to the rest of the chart. The tighter the orb, the harder the two are to separate.",
                facts: related.prefix(5).map { aspect in
                    "\(aspect.first.glyph) \(aspect.kind.glyph) \(aspect.second.glyph)  \(aspect.orbFormatted)"
                }
            )
        )

        let houseSection: PlacementDetail.Section
        if let house = placement.house.value, let houses = chart.houses.value {
            let match = houses.first { $0.id == house }
            houseSection = .init(
                id: "houses",
                title: "In houses",
                body: match?.summary ?? "The area of life this operates in.",
                facts: ["HOUSE \(house)  \(match?.title.uppercased() ?? "")"]
            )
        } else {
            houseSection = .init(
                id: "houses",
                title: "In houses",
                body: "Houses are measured from the horizon at the moment of birth, so they need an exact time and a place. Without those this is withheld rather than estimated.",
                facts: []
            )
        }
        sections.append(houseSection)

        return PlacementDetail(
            id: placement.id,
            system: .western,
            title: placement.planet.spokenName,
            subtitle: placement.position.sign.spokenName,
            precision: placement.position.degreeFormatted,
            glyph: placement.planet.glyph,
            glyphSpokenName: placement.planet.spokenName,
            sections: sections,
            provenance: provenance
        )
    }

    static func detail(
        for placement: GrahaPlacement,
        in chart: VedicChart,
        provenance: ContentProvenance
    ) -> PlacementDetail {
        var sections: [PlacementDetail.Section] = [
            .init(id: "meaning", title: "Meaning", body: placement.meaning, facts: [])
        ]

        sections.append(
            .init(
                id: "nakshatra",
                title: "Nakshatra",
                body: placement.nakshatra.value != nil
                    ? "The lunar mansion this falls in. Vedic reading treats the nakshatra as carrying more specific character than the rashi alone."
                    : "The nakshatra divides the circle into twenty-seven, so it needs a more precise position than a birth date can give.",
                facts: placement.nakshatra.value.map { ["NAKSHATRA  \($0.spokenName.uppercased())"] } ?? []
            )
        )

        sections.append(
            .init(
                id: "bhava",
                title: "In bhavas",
                body: placement.bhava.value != nil
                    ? "Bhavas are counted from the Lagna. They are not the same construct as Western houses and are not read the same way."
                    : "Bhavas are counted from the Lagna, which needs a birth time and place.",
                facts: placement.bhava.value.map { bhava in
                    ["BHAVA B\(bhava)  \(VedicChartFixtures.bhavas.first { $0.id == bhava }?.title.uppercased() ?? "")"]
                } ?? []
            )
        )

        return PlacementDetail(
            id: placement.id,
            system: .vedic,
            title: placement.graha.spokenName,
            subtitle: placement.rashi.spokenName,
            precision: placement.degreeFormatted,
            glyph: chart.triad.entries.first?.glyph ?? "☽",
            glyphSpokenName: placement.graha.spokenName,
            sections: sections,
            provenance: provenance
        )
    }

    static func detail(
        for pillar: Pillar,
        in chart: ChineseChart,
        provenance: ContentProvenance
    ) -> PlacementDetail {
        let sections: [PlacementDetail.Section] = [
            .init(id: "meaning", title: "Meaning", body: pillar.meaning, facts: []),
            .init(
                id: "elements",
                title: "Element",
                body: ChineseChartFixtures.dayMasterSummary(for: pillar.element),
                facts: [
                    "STEM  \(pillar.stem.han)  \(pillar.stem.spokenName.uppercased())",
                    "BRANCH  \(pillar.branch.han)  \(pillar.branch.animalSpokenName.uppercased())",
                ]
            ),
            .init(
                id: "interaction",
                title: "With the other pillars",
                body: "BaZi is read through how the four pillars meet — support, drain, control and combination between elements. There are no houses and no transits here; the relationships are between the pillars themselves.",
                facts: chart.elementBalance
                    .sorted { $0.key.rawValue < $1.key.rawValue }
                    .filter { $0.value > 0 }
                    .map { "\($0.key.han)  \($0.key.spokenName.uppercased())  ×\($0.value)" }
            ),
        ]

        return PlacementDetail(
            id: pillar.id.rawValue,
            system: .chinese,
            title: pillar.position.displayName,
            subtitle: pillar.han,
            precision: nil,
            glyph: pillar.branch.animalHan,
            glyphSpokenName: pillar.spokenDescription,
            sections: sections,
            provenance: provenance
        )
    }
}
