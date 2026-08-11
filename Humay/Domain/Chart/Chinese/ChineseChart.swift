import Foundation

/// The ten heavenly stems.
enum HeavenlyStem: String, Sendable, CaseIterable, Identifiable, Codable {
    case jia, yi, bing, ding, wu, ji, geng, xin, ren, gui

    var id: String { rawValue }

    var han: String {
        switch self {
        case .jia: "甲"
        case .yi: "乙"
        case .bing: "丙"
        case .ding: "丁"
        case .wu: "戊"
        case .ji: "己"
        case .geng: "庚"
        case .xin: "辛"
        case .ren: "壬"
        case .gui: "癸"
        }
    }

    var element: WuXing {
        switch self {
        case .jia, .yi: .wood
        case .bing, .ding: .fire
        case .wu, .ji: .earth
        case .geng, .xin: .metal
        case .ren, .gui: .water
        }
    }

    /// Yang stems are the odd-numbered ones.
    var isYang: Bool {
        (Self.allCases.firstIndex(of: self) ?? 0) % 2 == 0
    }

    var spokenName: String {
        "\(isYang ? "Yang" : "Yin") \(element.spokenName)"
    }
}

/// The twelve earthly branches.
enum EarthlyBranch: String, Sendable, CaseIterable, Identifiable, Codable {
    case zi, chou, yin, mao, chen, si, wu, wei, shen, you, xu, hai

    var id: String { rawValue }

    var han: String {
        switch self {
        case .zi: "子"
        case .chou: "丑"
        case .yin: "寅"
        case .mao: "卯"
        case .chen: "辰"
        case .si: "巳"
        case .wu: "午"
        case .wei: "未"
        case .shen: "申"
        case .you: "酉"
        case .xu: "戌"
        case .hai: "亥"
        }
    }

    /// The animal associated with the branch. Note this is a branch, not a "sign" —
    /// there is no zodiac here in the Western sense.
    var animalSpokenName: String {
        switch self {
        case .zi: "Rat"
        case .chou: "Ox"
        case .yin: "Tiger"
        case .mao: "Rabbit"
        case .chen: "Dragon"
        case .si: "Snake"
        case .wu: "Horse"
        case .wei: "Goat"
        case .shen: "Monkey"
        case .you: "Rooster"
        case .xu: "Dog"
        case .hai: "Pig"
        }
    }

    var animalHan: String {
        switch self {
        case .zi: "鼠"
        case .chou: "牛"
        case .yin: "虎"
        case .mao: "兔"
        case .chen: "龍"
        case .si: "蛇"
        case .wu: "馬"
        case .wei: "羊"
        case .shen: "猴"
        case .you: "雞"
        case .xu: "狗"
        case .hai: "豬"
        }
    }
}

/// The five phases.
enum WuXing: String, Sendable, CaseIterable, Identifiable, Codable {
    case wood, fire, earth, metal, water

    var id: String { rawValue }

    var spokenName: String {
        rawValue.prefix(1).uppercased() + rawValue.dropFirst()
    }

    var han: String {
        switch self {
        case .wood: "木"
        case .fire: "火"
        case .earth: "土"
        case .metal: "金"
        case .water: "水"
        }
    }
}

enum PillarPosition: String, Sendable, CaseIterable, Identifiable, Codable {
    case year, month, day, hour

    var id: String { rawValue }

    var displayName: String {
        "\(rawValue.prefix(1).uppercased() + rawValue.dropFirst()) pillar"
    }
}

/// One of the four pillars: a stem paired with a branch.
struct Pillar: Sendable, Hashable, Identifiable {
    var id: PillarPosition { position }
    let position: PillarPosition
    let stem: HeavenlyStem
    let branch: EarthlyBranch
    let meaning: String

    /// "癸卯"
    var han: String { stem.han + branch.han }

    var element: WuXing { stem.element }

    var spokenDescription: String {
        "\(position.displayName), \(stem.spokenName) \(branch.animalSpokenName)"
    }
}

/// The element of the Day Pillar's stem — the core the rest of the chart is read from.
struct DayMaster: Sendable, Hashable {
    let stem: HeavenlyStem
    let summary: String

    var element: WuXing { stem.element }
    var spokenName: String { stem.spokenName }
}

/// A ten-year luck period.
struct LuckCycle: Sendable, Hashable, Identifiable {
    let id: String
    let startAge: Int
    let pillar: Pillar
    let summary: String
}

/// A BaZi chart.
///
/// There is no `houses`, no `aspects`, no `transits` and no `rising` property here —
/// not withheld, but genuinely absent from the system. Chinese astrology reads element
/// interactions across four pillars; it does not track a moving sky against a natal
/// one, and the application does not pretend otherwise.
struct ChineseChart: Sendable, Hashable {
    let yearPillar: Pillar
    let monthPillar: FactValue<Pillar>
    let dayPillar: FactValue<Pillar>
    /// Needs a birth time. Genuinely unavailable without one.
    let hourPillar: FactValue<Pillar>
    let dayMaster: FactValue<DayMaster>
    let elementBalance: [WuXing: Int]
    /// The direction of the Luck Cycle depends on a convention that is not signed off,
    /// so this ships unavailable rather than shown as decided.
    let luckCycle: FactValue<[LuckCycle]>
    /// The calendar convention in force, stated because it changes the pillars.
    let calendarNote: String
    let headline: String
    let feature: ChartFeature
    let provenance: ContentProvenance

    var triad: ChartTriad {
        ChartTriad(entries: [
            .init(
                id: "year",
                label: "Year pillar",
                value: yearPillar.han,
                glyph: yearPillar.branch.animalHan,
                glyphSpokenName: yearPillar.spokenDescription,
                glossaryTermID: "pillar"
            ),
            .init(
                id: "dayMaster",
                label: "Day Master",
                value: dayMaster.value?.element.spokenName ?? "—",
                glyph: dayMaster.value?.element.han ?? "·",
                glyphSpokenName: dayMaster.value?.spokenName ?? "not available",
                glossaryTermID: "day-master"
            ),
            .init(
                id: "hour",
                label: "Hour pillar",
                value: hourPillar.value?.han ?? "—",
                glyph: hourPillar.value?.branch.animalHan ?? "·",
                glyphSpokenName: hourPillar.value?.spokenDescription ?? "not available",
                glossaryTermID: "pillar"
            ),
        ])
    }

    var pillars: [FactValue<Pillar>] {
        [.available(yearPillar), monthPillar, dayPillar, hourPillar]
    }
}
