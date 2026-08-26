import Foundation

/// Translates real sky events into feed language. The fact line is preserved
/// verbatim; the human headline is clearly interpretation, never a new fact.
enum SkyHeadlineTranslator {
    static func translate(_ event: SkyEvent) -> CosmicEventSeed {
        CosmicEventSeed(
            id: event.id.rawValue,
            humanHeadline: headline(for: event),
            factLine: factLine(for: event)
        )
    }

    private static func headline(for event: SkyEvent) -> String {
        let title = event.title.lowercased()

        if title.contains("mercury") && title.contains("retro") {
            return "Mercury has entered the group chat."
        }
        if title.contains("venus") {
            return "Venus changed the vibe."
        }
        if title.contains("mars") {
            return "Mars turned up the volume."
        }
        if title.contains("moon") {
            return "The moon has opinions tonight."
        }
        if title.contains("full moon") {
            return "Full moon. Everyone feels a lot. Coincidence? Sure."
        }
        if title.contains("new moon") {
            return "New moon. Fresh page, same handwriting."
        }
        if title.contains("saturn") {
            return "Saturn is doing compliance checks."
        }
        if title.contains("jupiter") {
            return "Jupiter thinks you deserve more. Jupiter might be right."
        }
        if event.type == .seasonalTransition {
            return "The seasons changed the subject."
        }

        return "The sky moved something around."
    }

    private static func factLine(for event: SkyEvent) -> String {
        switch event.timing {
        case .instant(let date):
            return "\(event.title) at \(date.formatted(date: .omitted, time: .shortened))."
        case .interval(let interval):
            return "\(event.title), \(interval.start.formatted(date: .omitted, time: .shortened))–\(interval.end.formatted(date: .omitted, time: .shortened))."
        case .dateOnly:
            return "\(event.title). Today."
        case .unavailable:
            return event.summary ?? event.title + "."
        }
    }
}
