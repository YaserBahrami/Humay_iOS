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

/// Transient onboarding input and confirmation state.
///
/// No profile is created while the user is moving the picker. A date enters the
/// Domain only after `confirmBirthDate()` succeeds from the explicit Continue action.
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
    private(set) var confirmedBirthDate: OnboardingBirthDate?

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
        self.confirmedBirthDate = nil
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

        return UserProfile(
            displayName: "",
            birth: confirmedBirthDate.birthDetails
        )
    }

    func pickerDateFormatted(locale: Locale = .current) -> String {
        pickerDate.formatted(.dateTime.day().month(.wide).year().locale(locale))
    }
}
