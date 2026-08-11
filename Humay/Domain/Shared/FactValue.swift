import Foundation

/// Why a fact is not available.
enum FactUnavailability: Sendable, Hashable {
    /// Needs an exact birth time. Rising, houses, the hour pillar, nakshatra precision.
    case requiresBirthTime
    /// Needs a birth place. Houses depend on longitude; everything depends on the
    /// historical time zone in force on the day.
    case requiresBirthPlace
    /// The methodology that would produce this is not signed off. Carries the tracking
    /// identifier from `docs/development/METHODOLOGY_TRACK.md`.
    case methodologyPending(methodID: String)

    var explanation: String {
        switch self {
        case .requiresBirthTime:
            "Needs your birth time"
        case .requiresBirthPlace:
            "Needs your birth place"
        case .methodologyPending:
            "Method still being decided"
        }
    }
}

/// A fact that may not be knowable.
///
/// The product rule is that an unknown birth time degrades only the facts that actually
/// depend on it, and is never quietly replaced with noon or midnight. Modelling that as
/// an enum rather than an optional means the *reason* travels with the absence, so the
/// interface can explain itself instead of showing a blank.
enum FactValue<Value: Sendable & Hashable>: Sendable, Hashable {
    case available(Value)
    /// Known within a window rather than exactly — an approximate birth time can put a
    /// placement between two signs, and the interface says so rather than picking one.
    case uncertain(Value, window: String)
    case unavailable(reason: FactUnavailability)

    var value: Value? {
        switch self {
        case .available(let value), .uncertain(let value, _): value
        case .unavailable: nil
        }
    }

    var isAvailable: Bool {
        if case .unavailable = self { return false }
        return true
    }

    var unavailability: FactUnavailability? {
        if case .unavailable(let reason) = self { return reason }
        return nil
    }

    func map<T>(_ transform: (Value) -> T) -> FactValue<T> {
        switch self {
        case .available(let value): .available(transform(value))
        case .uncertain(let value, let window): .uncertain(transform(value), window: window)
        case .unavailable(let reason): .unavailable(reason: reason)
        }
    }
}
