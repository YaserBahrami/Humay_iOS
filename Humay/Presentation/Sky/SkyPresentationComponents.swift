import SwiftUI

/// Compact disclosure that keeps Debug fixtures visibly separate from production output.
struct SkyDevelopmentNotice: View {
    var identifier = "sky.development-sample.notice"

    var body: some View {
        Label("Development sample · not calculated", systemImage: "hammer")
            .font(HumayTypography.caption)
            .foregroundStyle(Color.humayTextSecondary)
            .frame(minHeight: HumayMetrics.minimumHitTarget, alignment: .leading)
            .accessibilityElement(children: .combine)
            .accessibilityIdentifier(identifier)
    }
}

/// Persistent disclosure used when valid cached Sky content remains available offline.
struct SkyOfflineBanner: View {
    let title: String
    let detail: String
    let identifier: String

    var body: some View {
        HumayHairlineSurface(style: .quiet, padding: HumaySpacing.large) {
            HStack(alignment: .top, spacing: HumaySpacing.medium) {
                HumaySystemSymbolImage(symbol: .offline, size: .compact)
                    .foregroundStyle(Color.humayAccentPrestige)

                VStack(alignment: .leading, spacing: HumaySpacing.extraSmall) {
                    Text(title)
                        .font(HumayTypography.bodyEmphasized)
                    Text(detail)
                        .font(HumayTypography.supporting)
                        .foregroundStyle(Color.humayTextSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier(identifier)
    }
}

/// Shared editorial state shell. Product-distinct states keep their own copy and identifiers.
struct SkyStatePresentation: View {
    let symbol: String
    let title: String
    let message: String
    let identifier: String
    var eyebrow = "Sky status"
    var accent: Color = .humayAccentPrestige

    var body: some View {
        VStack(alignment: .leading, spacing: HumaySpacing.extraLarge) {
            HStack(spacing: HumaySpacing.medium) {
                Image(systemName: symbol)
                    .font(HumayTypography.statusSymbol)
                    .symbolRenderingMode(.monochrome)
                    .foregroundStyle(accent)
                    .frame(
                        width: HumayMetrics.minimumHitTarget,
                        height: HumayMetrics.minimumHitTarget
                    )
                    .accessibilityHidden(true)

                HumayEyebrow(text: eyebrow, color: accent)
            }

            Divider()
                .overlay(Color.humaySeparator)

            VStack(alignment: .leading, spacing: HumaySpacing.medium) {
                Text(title)
                    .font(HumayTypography.detailTitle)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityAddTraits(.isHeader)

                Text(message)
                    .font(HumayTypography.body)
                    .foregroundStyle(Color.humayTextSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: HumayContentWidth.readable.rawValue, alignment: .leading)
        }
        .padding(.vertical, HumaySpacing.large)
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier(identifier)
    }
}

struct SkyLoadingPresentation: View {
    let title: String
    let message: String
    let identifier: String

    var body: some View {
        VStack(alignment: .leading, spacing: HumaySpacing.extraLarge) {
            ProgressView()
                .controlSize(.large)
                .tint(Color.humayAccentPrestige)
                .frame(
                    width: HumayMetrics.minimumHitTarget,
                    height: HumayMetrics.minimumHitTarget
                )
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: HumaySpacing.small) {
                Text(title)
                    .font(HumayTypography.detailTitle)
                    .accessibilityAddTraits(.isHeader)
                Text(message)
                    .font(HumayTypography.body)
                    .foregroundStyle(Color.humayTextSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(.vertical, HumaySpacing.extraLarge)
        .frame(maxWidth: HumayContentWidth.readable.rawValue, alignment: .leading)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title). \(message)")
        .accessibilityIdentifier(identifier)
    }
}

/// One concise statement of where, when, and under which methodology Sky content applies.
struct SkyObservationMetadata: View {
    let context: SkyObservationContext
    var observedAt: Date?
    var methodology: SkyEventSystem?
    var note: String?

    var body: some View {
        VStack(alignment: .leading, spacing: HumaySpacing.medium) {
            HumayEyebrow(text: "Observation context", color: .humayAccentCelestial)

            ViewThatFits(in: .horizontal) {
                HStack(alignment: .firstTextBaseline, spacing: HumaySpacing.large) {
                    metadataItems
                }

                VStack(alignment: .leading, spacing: HumaySpacing.small) {
                    metadataItems
                }
            }
        }
        .accessibilityElement(children: .combine)
    }

    @ViewBuilder
    private var metadataItems: some View {
        metadataItem(
            SkyEventTimingFormatter.contextText(for: context),
            symbol: context.locationName == nil ? "globe" : "location"
        )

        if let observedAt {
            metadataItem(
                SkyEventTimingFormatter.observationText(for: observedAt, context: context),
                symbol: "clock"
            )
        }

        if let methodology {
            metadataItem(
                SkyMethodologyFormatter.label(for: methodology),
                symbol: "books.vertical"
            )
        }

        if let note {
            metadataItem(note, symbol: "info.circle")
        }
    }

    private func metadataItem(_ text: String, symbol: String) -> some View {
        Label(text, systemImage: symbol)
            .font(HumayTypography.supporting)
            .foregroundStyle(Color.humayTextSecondary)
            .fixedSize(horizontal: false, vertical: true)
    }
}

enum SkyEventTimingPresentation {
    case current(observedAt: Date?)
    case calendar
}

/// Shared factual event row used by Current Sky and Calendar agendas.
struct SkyEventRow: View {
    let event: SkyEvent
    let context: SkyObservationContext?
    var timingPresentation: SkyEventTimingPresentation = .calendar
    var showsSummary = true
    var showsDisclosure = true

    var body: some View {
        HStack(alignment: .top, spacing: HumaySpacing.medium) {
            SkyEventGlyph(event: event)

            VStack(alignment: .leading, spacing: HumaySpacing.small) {
                Text(event.title)
                    .font(HumayTypography.bodyEmphasized)
                    .foregroundStyle(Color.humayTextPrimary)
                    .fixedSize(horizontal: false, vertical: true)

                if showsSummary, let summary = event.summary {
                    Text(summary)
                        .font(HumayTypography.supporting)
                        .foregroundStyle(Color.humayTextSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                ViewThatFits(in: .horizontal) {
                    HStack(alignment: .firstTextBaseline, spacing: HumaySpacing.medium) {
                        timingText
                        Spacer(minLength: HumaySpacing.small)
                        secondaryMetadata
                    }

                    VStack(alignment: .leading, spacing: HumaySpacing.small) {
                        timingText
                        secondaryMetadata
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            if showsDisclosure {
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.humayTextSecondary)
                    .frame(
                        width: HumayMetrics.minimumHitTarget,
                        height: HumayMetrics.minimumHitTarget
                    )
                    .accessibilityHidden(true)
            }
        }
        .frame(minHeight: HumayMetrics.minimumHitTarget, alignment: .leading)
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentShape(Rectangle())
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityLabel)
        .accessibilityValue(accessibilityValue)
    }

    private var timingText: some View {
        Text(timing)
            .font(HumayTypography.supporting)
            .monospacedDigit()
            .foregroundStyle(Color.humayTextSecondary)
            .fixedSize(horizontal: false, vertical: true)
    }

    private var secondaryMetadata: some View {
        HStack(spacing: HumaySpacing.medium) {
            Text(SkyMethodologyFormatter.label(for: event.system))
                .font(HumayTypography.utility)
                .foregroundStyle(event.style.accent)

            if let reliabilityQualifier {
                Label(reliabilityQualifier, systemImage: "plusminus")
                    .font(HumayTypography.utility)
                    .foregroundStyle(Color.humayTextSecondary)
            }
        }
        .fixedSize(horizontal: false, vertical: true)
    }

    private var timing: String {
        guard let context else { return "Timing unavailable" }
        return switch timingPresentation {
        case .current(let observedAt):
            SkyEventTimingFormatter.text(
                for: event.timing,
                context: context,
                observedAt: observedAt
            )
        case .calendar:
            SkyEventTimingFormatter.calendarText(for: event.timing, context: context)
        }
    }

    private var reliabilityQualifier: String? {
        return switch event.reliability {
        case .approximate:
            "Approximate"
        case .reliable, .unverified:
            nil
        }
    }

    private var accessibilityLabel: String {
        "\(event.title), \(SkyEventTypeFormatter.label(for: event.type)), "
            + SkyMethodologyFormatter.label(for: event.system)
    }

    private var accessibilityValue: String {
        "\(timing), \(SkyEventReliabilityFormatter.label(for: event.reliability))"
    }
}

/// Generic event-family cue. Domain does not expose exact planets/aspect kinds, so
/// verified technical glyphs are deliberately not inferred from event titles.
struct SkyEventGlyph: View {
    let event: SkyEvent
    var size: CGFloat = 18

    var body: some View {
        Image(systemName: event.style.symbol)
            .font(.system(size: size, weight: .regular))
            .symbolRenderingMode(.monochrome)
            .foregroundStyle(event.style.accent)
            .frame(
                width: HumayMetrics.minimumHitTarget,
                height: HumayMetrics.minimumHitTarget
            )
            .accessibilityHidden(true)
    }
}

extension SkyEvent {
    var style: SkyEventStyle {
        SkyEventStyle(type: type, system: system)
    }
}

struct SkyEventStyle {
    let accent: Color
    let symbol: String

    init(type: SkyEventType, system: SkyEventSystem) {
        switch type {
        case .lunarPhase:
            accent = .humayAccentPrestige
            symbol = "moon.stars"
        case .planetaryIngress:
            accent = .humayAccentCelestial
            symbol = "arrow.right.to.line.compact"
        case .planetaryAspect:
            accent = .humayAccentCelestial
            symbol = "circle.grid.cross"
        case .planetaryStation:
            accent = .humayChartHarmonious
            symbol = "pause.circle"
        case .seasonalTransition:
            accent = .humayAccentPrestige
            symbol = "sun.horizon"
        case .traditionSpecific:
            accent = system == .astrological(.vedic)
                ? .humayAccentCelestial
                : .humayAccentPrestige
            symbol = "books.vertical"
        }
    }
}

struct SkySelectedDateHeader: View {
    let date: SkyCalendarDate
    let eventCount: Int

    var body: some View {
        ViewThatFits(in: .horizontal) {
            HStack(alignment: .lastTextBaseline, spacing: HumaySpacing.large) {
                title
                Spacer(minLength: HumaySpacing.small)
                count
            }

            VStack(alignment: .leading, spacing: HumaySpacing.small) {
                title
                count
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("sky.calendar.selected-date.heading")
    }

    private var title: some View {
        VStack(alignment: .leading, spacing: HumaySpacing.extraSmall) {
            HumayEyebrow(text: "Selected date", color: .humayAccentPrestige)
            Text(SkyCalendarSupport.selectedDateTitle(date))
                .font(HumayTypography.editorialTitle)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityAddTraits(.isHeader)
        }
    }

    private var count: some View {
        Text("\(eventCount) event\(eventCount == 1 ? "" : "s")")
            .font(HumayTypography.utility)
            .foregroundStyle(Color.humayTextSecondary)
            .textCase(.uppercase)
    }
}
