import SwiftUI

struct ProfileRevealView: View {
    let birthDate: OnboardingBirthDate
    var displayName: String = ""
    let tradition: AstrologyTradition
    let onBack: () -> Void
    let onEnterHumay: () -> Void

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    private var firstName: String {
        String(displayName.split(whereSeparator: \.isWhitespace).first ?? "")
    }

    private var sunSign: WesternZodiacSign? {
        SunSignCalendar.westernSunSign(month: birthDate.month, day: birthDate.day)
    }

    private var headlineTitle: String {
        if firstName.isEmpty {
            return "Your starting profile is ready"
        }
        return "\(firstName), meet your Sun sign."
    }

    var body: some View {
        GeometryReader { proxy in
            let metrics = ProfileRevealLayoutMetrics(proxy: proxy)

            Group {
                if dynamicTypeSize.isAccessibilitySize {
                    scrollFallback(metrics: metrics)
                } else {
                    ViewThatFits(in: .vertical) {
                        fittedContent(metrics: metrics)
                        scrollFallback(metrics: metrics)
                    }
                }
            }
            .padding(.horizontal, metrics.gutter)
            .padding(.vertical, metrics.verticalPadding)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
        .background(Color.humayGround.ignoresSafeArea())
    }

    @ViewBuilder
    private func fittedContent(metrics: ProfileRevealLayoutMetrics) -> some View {
        if metrics.usesWideLandscapeLayout {
            landscapeContent(metrics: metrics)
        } else {
            portraitContent(metrics: metrics)
        }
    }

    private func portraitContent(metrics: ProfileRevealLayoutMetrics) -> some View {
        VStack(alignment: .leading, spacing: metrics.sectionSpacing) {
            OnboardingChrome(
                stepLabel: "04 · Your reveal",
                progressIndex: 4,
                onBack: onBack
            )

            OnboardingTitleBlock(
                title: headlineTitle,
                supporting: "A simple beginning — no fake precision.",
                hero: false
            )

            if let sunSign {
                SunSignRevealCard(sign: sunSign)
            }

            profileFacts(
                compact: metrics.isCompactHeight,
                padding: metrics.cardPadding
            )

            Spacer(minLength: 0)

            primaryAction
        }
        .frame(maxWidth: 720, alignment: .leading)
        .frame(
            maxWidth: .infinity,
            minHeight: metrics.contentHeight,
            alignment: .top
        )
    }

    private func landscapeContent(metrics: ProfileRevealLayoutMetrics) -> some View {
        VStack(alignment: .leading, spacing: metrics.sectionSpacing) {
            OnboardingChrome(
                stepLabel: "04 · Your reveal",
                progressIndex: 4,
                onBack: onBack
            )

            OnboardingTitleBlock(
                title: headlineTitle,
                supporting: "A simple beginning — no fake precision.",
                hero: false
            )

            HStack(alignment: .top, spacing: HumaySpacing.extraExtraLarge) {
                VStack(alignment: .leading, spacing: metrics.sectionSpacing) {
                    if let sunSign {
                        SunSignRevealCard(sign: sunSign)
                    }

                    primaryAction
                }
                .frame(maxWidth: 430)

                profileFacts(
                    compact: false,
                    padding: metrics.cardPadding
                )
                .frame(maxWidth: 520)
            }
            .frame(maxWidth: 1000)
            .frame(maxWidth: .infinity, alignment: .center)
        }
        .frame(
            maxWidth: .infinity,
            minHeight: metrics.contentHeight,
            alignment: .top
        )
    }

    private func scrollFallback(metrics: ProfileRevealLayoutMetrics) -> some View {
        ScrollView {
            fittedContent(metrics: metrics)
                .frame(minHeight: 0)
                .padding(.bottom, HumaySpacing.small)
        }
        .scrollIndicators(.hidden)
    }

    private func profileFacts(compact: Bool, padding: CGFloat) -> some View {
        HumaySurface(padding: padding) {
            VStack(alignment: .leading, spacing: compact ? HumaySpacing.small : HumaySpacing.medium) {
                Text("YOUR STARTING PROFILE")
                    .font(HumayTypography.utility)
                    .foregroundStyle(Color.humayCoral)
                    .tracking(1.2)

                if !firstName.isEmpty {
                    ProfileFactRow(label: "Name", value: firstName)
                }
                ProfileFactRow(
                    label: "Birth date",
                    value: birthDate.formatted()
                )
                ProfileFactRow(
                    label: "Starting tradition",
                    value: tradition.shortName
                )

                Divider()
                    .overlay(Color.humayHairline)

                HStack(alignment: .top, spacing: HumaySpacing.small) {
                    Image(systemName: "sparkles")
                        .font(.system(size: compact ? 14 : 16, weight: .semibold))
                        .foregroundStyle(Color.humayLavender)
                        .frame(width: 28, height: 28)
                        .background(Color.humayLavender.opacity(0.12), in: Circle())
                        .accessibilityHidden(true)

                    VStack(alignment: .leading, spacing: HumaySpacing.extraSmall) {
                        Text("Precision stays optional")
                            .font(HumayTypography.bodyEmphasized)

                        Text("Add birth time and place later only when something genuinely needs them — Humay will say when.")
                            .font(HumayTypography.supporting)
                            .foregroundStyle(Color.humayTextSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .accessibilityElement(children: .combine)
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("onboarding.profileReveal.summary")
    }

    private var primaryAction: some View {
        OnboardingPrimaryAction(
            title: "Enter Humay",
            identifier: "onboarding.profileReveal.enter",
            action: onEnterHumay
        )
        .frame(maxWidth: .infinity, alignment: .center)
    }
}

/// The Sun sign moment: zodiac art + Humay's one-liner. Level 1 fun only.
private struct SunSignRevealCard: View {
    let sign: WesternZodiacSign

    var body: some View {
        HStack(alignment: .center, spacing: HumaySpacing.large) {
            ZodiacSignArt(sign: sign, size: 84)

            VStack(alignment: .leading, spacing: HumaySpacing.extraSmall) {
                Text("SUN SIGN")
                    .font(HumayTypography.utility)
                    .tracking(1.3)
                    .foregroundStyle(Color.humayCoral)

                Text("\(sign.displayName) \(sign.glyph)")
                    .font(HumayTypography.editorialTitle)
                    .accessibilityAddTraits(.isHeader)

                Text(sign.humayTagline)
                    .font(HumayTypography.body)
                    .foregroundStyle(Color.humayTextSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(HumaySpacing.extraLarge)
        .background(Color.humayRaisedSurface, in: RoundedRectangle(cornerRadius: HumayRadius.feature))
        .overlay {
            RoundedRectangle(cornerRadius: HumayRadius.feature)
                .stroke(Color.humayHairline, lineWidth: 1)
        }
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("onboarding.profileReveal.sunSign")
    }
}

private struct ProfileFactRow: View {
    let label: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: HumaySpacing.extraSmall) {
            Text(label)
                .font(HumayTypography.utility)
                .foregroundStyle(Color.humayTextSecondary)

            Text(value)
                .font(HumayTypography.bodyEmphasized)
                .foregroundStyle(Color.humayTextPrimary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .accessibilityElement(children: .combine)
    }
}

private struct ProfileRevealLayoutMetrics {
    let size: CGSize
    let safeAreaInsets: EdgeInsets

    init(proxy: GeometryProxy) {
        size = proxy.size
        safeAreaInsets = proxy.safeAreaInsets
    }

    private var usableHeight: CGFloat {
        max(size.height - safeAreaInsets.top - safeAreaInsets.bottom, 0)
    }

    var isCompactHeight: Bool {
        usableHeight < 700
    }

    var usesWideLandscapeLayout: Bool {
        size.width > size.height && size.width >= 840
    }

    var gutter: CGFloat {
        bounded(size.width * 0.05, minimum: 16, maximum: 32)
    }

    var verticalPadding: CGFloat {
        bounded(usableHeight * 0.014, minimum: 8, maximum: 16)
    }

    var sectionSpacing: CGFloat {
        bounded(
            usableHeight * (isCompactHeight ? 0.012 : 0.016),
            minimum: 8,
            maximum: 16
        )
    }

    var heroHeight: CGFloat {
        if isCompactHeight {
            return bounded(usableHeight * 0.245, minimum: 140, maximum: 165)
        }

        return bounded(usableHeight * 0.275, minimum: 170, maximum: 240)
    }

    var cardPadding: CGFloat {
        bounded(size.width * 0.045, minimum: 14, maximum: 22)
    }

    var contentHeight: CGFloat {
        max(usableHeight - (verticalPadding * 2), 0)
    }

    private func bounded(_ value: CGFloat, minimum: CGFloat, maximum: CGFloat) -> CGFloat {
        min(max(value, minimum), maximum)
    }
}

#Preview("Profile Reveal Light") {
    ProfileRevealView(
        birthDate: OnboardingBirthDate(year: 1994, month: 3, day: 14),
        tradition: .western,
        onBack: {},
        onEnterHumay: {}
    )
    .preferredColorScheme(.light)
}

#Preview("Profile Reveal Dark") {
    ProfileRevealView(
        birthDate: OnboardingBirthDate(year: 1994, month: 3, day: 14),
        tradition: .western,
        onBack: {},
        onEnterHumay: {}
    )
    .preferredColorScheme(.dark)
}
