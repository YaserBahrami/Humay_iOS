import Foundation

/// Presentation-ready naming for the normalized tropical signs. Kept in Domain so
/// every layer shares one canonical display vocabulary.
extension WesternZodiacSign {
    var displayName: String {
        rawValue.capitalized
    }

    /// Unicode zodiac glyph. Used sparingly — Humay avoids glyph-heavy astrology
    /// clichés, but the reveal moment earns one.
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

    /// The element bucket used by compatibility flavoring.
    var elementName: String {
        Element.of(self).rawValue.capitalized
    }
}
