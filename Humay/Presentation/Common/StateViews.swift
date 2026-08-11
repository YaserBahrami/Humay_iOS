import SwiftUI

/// Loading.
///
/// Named for what it is doing rather than showing a generic spinner. "Reading your
/// placements" is honest about interpreting something already known; it would be
/// dishonest if it implied a calculation were happening.
struct LoadingState: View {
    let message: String

    @Environment(\.humayTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        HStack(spacing: HumaySpacing.s) {
            if !reduceMotion {
                ProgressView()
                    .controlSize(.small)
                    .tint(theme.colors.accentMark)
            }
            Text(message)
                .humayFont(.callout)
                .foregroundStyle(theme.colors.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, HumaySpacing.l)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(message)
    }
}

/// Nothing here yet, and what to do about it.
struct EmptyStateView: View {
    let title: String
    let message: String
    var actionTitle: String?
    var action: (() -> Void)?

    @Environment(\.humayTheme) private var theme

    var body: some View {
        VStack(alignment: .leading, spacing: HumaySpacing.s) {
            Text(title)
                .humayFont(.titleM)
                .foregroundStyle(theme.colors.textPrimary)
            Text(message)
                .humayFont(.bodySmall)
                .foregroundStyle(theme.colors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
            if let actionTitle, let action {
                Button(actionTitle, action: action)
                    .buttonStyle(.humayOutline)
                    .padding(.top, HumaySpacing.xs)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, HumaySpacing.l)
    }
}

/// Something did not work, and whether trying again is worth it.
struct ErrorStateView: View {
    let message: String
    var retry: (() -> Void)?

    @Environment(\.humayTheme) private var theme

    var body: some View {
        VStack(alignment: .leading, spacing: HumaySpacing.s) {
            MonoKicker(text: "Not available")
            Text(message)
                .humayFont(.bodySmall)
                .foregroundStyle(theme.colors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
            if let retry {
                Button("Try again", action: retry)
                    .buttonStyle(.humayOutline)
                    .padding(.top, HumaySpacing.xs)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, HumaySpacing.l)
    }
}

/// Explains a fact that is not available, instead of showing a blank.
///
/// This is the visible half of the unknown-birth-time rule. A withheld value says why
/// it is withheld and what would make it available, which is the difference between an
/// honest gap and a broken screen.
struct UnavailableFactView: View {
    let reason: FactUnavailability
    var compact: Bool = false

    @Environment(\.humayTheme) private var theme
    @Environment(\.openHumaySettings) private var openSettings

    var body: some View {
        VStack(alignment: .leading, spacing: HumaySpacing.xs) {
            Text(explanation)
                .humayFont(compact ? .caption : .callout)
                .foregroundStyle(theme.colors.textTertiary)
                .fixedSize(horizontal: false, vertical: true)
            if needsBirthDetails, !compact {
                Button("Add birth details") { openSettings(.birthDetails) }
                    .buttonStyle(.humayQuiet)
            }
        }
        .accessibilityElement(children: .combine)
    }

    private var needsBirthDetails: Bool {
        switch reason {
        case .requiresBirthTime, .requiresBirthPlace: true
        case .methodologyPending: false
        }
    }

    private var explanation: String {
        switch reason {
        case .requiresBirthTime:
            "This needs your birth time. It is withheld rather than estimated — a placement with the wrong time is worse than no placement."
        case .requiresBirthPlace:
            "This needs your birth place. Longitude sets the houses, and the time zone in force on the day sets almost everything else."
        case .methodologyPending(let methodID):
            "The method behind this has not been settled, so it is not shown as decided. Tracked as \(methodID)."
        }
    }
}
