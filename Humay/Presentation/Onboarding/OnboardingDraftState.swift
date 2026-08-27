import Foundation
import Observation

/// Date-only input owned by onboarding Presentation.
///
/// The `Date` used by SwiftUI is only a picker cursor. The confirmed value remains
/// year/month/day components until it is turned into the Domain birth details.
struct OnboardingBirthDate: Sendable, Hashable {
    let year: Int
    let month: Int
    let day: Int

    init(year: Int, month: Int, day: Int) {
        self.year = year
        self.month = month
        self.day = day
    }

    init?(date: Date, calendar: Calendar) {
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        guard let year = components.year,
              let month = components.month,
              let day = components.day else {
            return nil
        }

        self.init(year: year, month: month, day: day)
    }

    var birthDetails: BirthDetails {
        BirthDetails(year: year, month: month, day: day)
    }

    func date(in calendar: Calendar) -> Date? {
        calendar.date(from: DateComponents(year: year, month: month, day: day))
    }

    func formatted(locale: Locale = .current) -> String {
        birthDetails.dateFormatted(locale: locale)
    }
}

/// Onboarding birth-time selection semantics (exact / approximate / unknown).
enum OnboardingTimeKind: String, Sendable, Hashable, CaseIterable {
    case exact
    case approximate
    case unknown
}

/// Transient onboarding input and confirmation state.
///
/// No profile is created while the user is moving the picker. A date enters the
/// Domain only after `confirmBirthDate()` succeeds from the explicit Continue action.
/// Time and place are now genuinely collected (§5) with honest unknown semantics.
@Observable
@MainActor
final class OnboardingDraftState {
    @ObservationIgnored private let calendar: Calendar

    let earliestValidDate: Date
    let latestValidDate: Date

    var pickerDate: Date {
        didSet {
            if pickerDate != oldValue {
                confirmedBirthDate = nil
            }
        }
    }

    var selectedTradition: AstrologyTradition
    var displayName: String
    private(set) var confirmedBirthDate: OnboardingBirthDate?

    // MARK: Birth time ( §7-10 )

    var timeKind: OnboardingTimeKind = .unknown

    /// Underlying Date for the time picker wheel. Only hour/minute are semantically used.
    /// Stored as minutesFromMidnight-derived Date so VoiceOver + wheel behave natively.
    var timePickerDate: Date {
        didSet {
            // Keep minutes in sync
            syncTimeMinutesFromPicker()
        }
    }

    /// Minutes from midnight for exact / central approximate time.
    var timeMinutesFromMidnight: Int = 12 * 60 + 0 // default noon for placeholder

    /// Tolerance for approximate (§9): 15, 30, 60 minutes.
    var approximateToleranceMinutes: Int = 30

    // MARK: Birth place ( §11-14 )

    var birthPlaceResult: BirthPlaceSearchResult?
    var birthPlaceQuery: String = ""

    init(
        now: Date = .now,
        calendar: Calendar = .autoupdatingCurrent,
        selectedTradition: AstrologyTradition = .western
    ) {
        var gregorian = Calendar(identifier: .gregorian)
        gregorian.timeZone = calendar.timeZone
        gregorian.locale = calendar.locale
        self.calendar = gregorian

        let earliest = gregorian.date(
            from: DateComponents(year: 1900, month: 1, day: 1)
        )!
        let todayComponents = gregorian.dateComponents([.year, .month, .day], from: now)
        let latest = gregorian.date(from: todayComponents) ?? gregorian.startOfDay(for: now)

        self.earliestValidDate = earliest
        self.latestValidDate = latest
        self.pickerDate = max(earliest, latest)
        self.selectedTradition = selectedTradition
        self.displayName = ""
        self.confirmedBirthDate = nil
        // Time picker default: 12:00 via Gregorian
        self.timePickerDate = gregorian.date(from: DateComponents(hour: 12, minute: 0)) ?? Date()
        self.timeMinutesFromMidnight = 12 * 60
    }

    private func syncTimeMinutesFromPicker() {
        let comps = calendar.dateComponents([.hour, .minute], from: timePickerDate)
        if let h = comps.hour, let m = comps.minute {
            timeMinutesFromMidnight = h * 60 + m
        }
    }

    func setExactTime(minutes: Int) {
        timeKind = .exact
        timeMinutesFromMidnight = max(0, min(1439, minutes))
        var comps = calendar.dateComponents([.year, .month, .day], from: Date())
        comps.hour = timeMinutesFromMidnight / 60
        comps.minute = timeMinutesFromMidnight % 60
        if let d = calendar.date(from: comps) {
            timePickerDate = d
        }
    }

    // MARK: Domain mapping

    var birthTime: BirthTime {
        switch timeKind {
        case .exact:
            return .exact(minutesFromMidnight: max(0, min(1439, timeMinutesFromMidnight)))
        case .approximate:
            return .approximate(minutesFromMidnight: max(0, min(1439, timeMinutesFromMidnight)), toleranceMinutes: max(1, approximateToleranceMinutes))
        case .unknown:
            return .unknown
        }
    }

    var birthPlace: BirthPlace {
        guard let r = birthPlaceResult else { return .notProvided }
        return r.birthPlace
    }

    var draftBirthDetails: BirthDetails? {
        guard let d = confirmedBirthDate else { return nil }
        return BirthDetails(year: d.year, month: d.month, day: d.day, time: birthTime, place: birthPlace)
    }

    /// Whether the current draft has enough data for an honest Big Three preview.
    var canPreviewBigThree: Bool {
        confirmedBirthDate != nil
    }

    var previewBigThree: BigThree? {
        guard let details = draftBirthDetails else { return nil }
        return BigThreeSyncHelper.compute(birth: details)
    }

    @discardableResult
    func confirmBirthDate() -> Bool {
        guard let candidate = OnboardingBirthDate(date: pickerDate, calendar: calendar),
              let candidateDate = candidate.date(in: calendar),
              candidateDate >= earliestValidDate,
              candidateDate <= latestValidDate else {
            return false
        }

        confirmedBirthDate = candidate
        return true
    }

    func makeProfile() -> UserProfile? {
        guard let confirmedBirthDate else { return nil }

        let details = BirthDetails(
            year: confirmedBirthDate.year,
            month: confirmedBirthDate.month,
            day: confirmedBirthDate.day,
            time: birthTime,
            place: birthPlace
        )
        return UserProfile(
            displayName: displayName.trimmingCharacters(in: .whitespacesAndNewlines),
            birth: details
        )
    }

    func pickerDateFormatted(locale: Locale = .current) -> String {
        pickerDate.formatted(.dateTime.day().month(.wide).year().locale(locale))
    }

    // MARK: Convenience for tests

    func setBirthPlace(_ result: BirthPlaceSearchResult?) {
        birthPlaceResult = result
    }
}
