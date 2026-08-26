import SwiftUI

extension Color {
    /// Semantic mapping from content-category accents to the approved palette.
    static func humay(_ accent: FeedAccent) -> Color {
        switch accent {
        case .coral: .humayCoral
        case .gold: .humaySolarGold
        case .lavender: .humayLavender
        case .sage: .humaySage
        case .ink: .humayTextPrimary
        }
    }
}

/// Small uppercase section label used across feed items and detail surfaces.
struct HumayKickerLabel: View {
    let text: String
    var tint: Color = .humayTextSecondary

    var body: some View {
        Text(text)
            .font(HumayTypography.utility)
            .textCase(.uppercase)
            .tracking(1.2)
            .foregroundStyle(tint)
            .accessibilityAddTraits(.isHeader)
    }
}

/// One animated entertainment meter: label, big numeral, thin fill bar.
/// The textual caption is always present so meaning never depends on color alone.
struct HumayMeter: View {
    let meter: FunMeter

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var progress: Double = 0

    private var fraction: Double { Double(meter.value) / 100 }

    var body: some View {
        VStack(alignment: .leading, spacing: HumaySpacing.extraSmall) {
            HStack(alignment: .firstTextBaseline) {
                Text(meter.metric.displayName)
                    .font(HumayTypography.supportingEmphasized)
                    .foregroundStyle(Color.humayTextSecondary)
                Spacer(minLength: HumaySpacing.small)
                Text("\(meter.value)%")
                    .font(HumayTypography.meterValue)
                    .monospacedDigit()
                    .contentTransition(.numericText())
                    .foregroundStyle(Color.humay(accent))
            }

            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.humayHairline)
                    Capsule()
                        .fill(Color.humay(accent))
                        .frame(width: proxy.size.width * progress)
                }
            }
            .frame(height: 6)
            .accessibilityHidden(true)

            if let caption = meter.caption {
                Text(caption)
                    .font(HumayTypography.supporting)
                    .foregroundStyle(Color.humayTextSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(meter.metric.displayName))
        .accessibilityValue(Text("\(meter.value) out of 100. \(meter.caption ?? "")"))
        .onAppear {
            withAnimation(HumayMotion.animated(HumayMotion.gentle.delay(0.08), enabled: !reduceMotion)) {
                progress = fraction
            }
        }
        .onChange(of: meter.value) { _, newValue in
            withAnimation(HumayMotion.animated(HumayMotion.snappy, enabled: !reduceMotion)) {
                progress = Double(newValue) / 100
            }
        }
    }

    private var accent: FeedAccent {
        FeedAccent.accent(for: meter.metric)
    }
}

/// A group of meters under one heading.
struct HumayMeterSet: View {
    let content: MeterSetContent

    var body: some View {
        VStack(alignment: .leading, spacing: HumaySpacing.large) {
            HumayKickerLabel(text: content.title)

            VStack(spacing: HumaySpacing.large) {
                ForEach(content.meters) { meter in
                    HumayMeter(meter: meter)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

/// Standard press behavior for tappable cards: slight scale + dim.
struct HumayPressableStyle: ButtonStyle {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .opacity(configuration.isPressed ? 0.82 : 1)
            .scaleEffect(configuration.isPressed && !reduceMotion ? 0.985 : 1)
            .animation(reduceMotion ? nil : Animation.easeOut(duration: HumayMotion.fastDuration), value: configuration.isPressed)
    }
}

extension ButtonStyle where Self == HumayPressableStyle {
    static var humayPressable: HumayPressableStyle { HumayPressableStyle() }
}
