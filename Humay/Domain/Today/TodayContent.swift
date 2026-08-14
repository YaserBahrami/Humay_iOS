import Foundation

/// Periods owned by the daily-reading feature.
enum HoroscopePeriod: String, CaseIterable, Identifiable, Sendable, Hashable {
    case today
    case tomorrow
    case thisWeek

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .today: "Today"
        case .tomorrow: "Tomorrow"
        case .thisWeek: "This Week"
        }
    }
}

enum DailyReadingCategory: String, CaseIterable, Identifiable, Sendable, Hashable {
    case love
    case career
    case money
    case health

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .love: "Love"
        case .career: "Career"
        case .money: "Money"
        case .health: "Health"
        }
    }
}

struct DailyReadingHighlight: Identifiable, Sendable, Hashable {
    let category: DailyReadingCategory
    let text: String

    var id: DailyReadingCategory { category }
}

/// Basis is explicit so coarse catalog copy cannot masquerade as natal personalization.
enum DailyReadingBasis: Sendable, Hashable {
    case freeWesternSunSign(WesternZodiacSign)
    case precisePersonalized

    var isPrecise: Bool {
        if case .precisePersonalized = self { return true }
        return false
    }
}

/// Humay-owned content contract for the Today landing screen.
struct TodayContent: Sendable, Hashable {
    let greeting: String
    let introduction: String
    let cosmicInsight: String
    let highlights: [DailyReadingHighlight]
    let roastTitle: String
    let roastBody: String
}

/// Humay-owned content contract for one daily reading period.
struct DailyHoroscopeContent: Sendable, Hashable {
    let period: HoroscopePeriod
    let date: Date
    let sign: WesternZodiacSign
    let basis: DailyReadingBasis
    let headline: String
    let body: String
    let highlights: [DailyReadingHighlight]
    let tip: String

    var hasCompleteCategorySet: Bool {
        Set(highlights.map(\.category)) == Set(DailyReadingCategory.allCases)
    }
}

extension WesternZodiacSign {
    var displayName: String {
        rawValue.capitalized
    }

    var glyph: String {
        switch self {
        case .aries: "♈︎"
        case .taurus: "♉︎"
        case .gemini: "♊︎"
        case .cancer: "♋︎"
        case .leo: "♌︎"
        case .virgo: "♍︎"
        case .libra: "♎︎"
        case .scorpio: "♏︎"
        case .sagittarius: "♐︎"
        case .capricorn: "♑︎"
        case .aquarius: "♒︎"
        case .pisces: "♓︎"
        }
    }

    var dateRange: String {
        switch self {
        case .aries: "Mar 21–Apr 19"
        case .taurus: "Apr 20–May 20"
        case .gemini: "May 21–Jun 20"
        case .cancer: "Jun 21–Jul 22"
        case .leo: "Jul 23–Aug 22"
        case .virgo: "Aug 23–Sep 22"
        case .libra: "Sep 23–Oct 22"
        case .scorpio: "Oct 23–Nov 21"
        case .sagittarius: "Nov 22–Dec 21"
        case .capricorn: "Dec 22–Jan 19"
        case .aquarius: "Jan 20–Feb 18"
        case .pisces: "Feb 19–Mar 20"
        }
    }
}
