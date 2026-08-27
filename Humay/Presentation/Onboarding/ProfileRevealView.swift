import SwiftUI

struct ProfileRevealView: View {
    let birthDate: OnboardingBirthDate
    var displayName: String = ""
    var birthDetails: BirthDetails? = nil
    let tradition: AstrologyTradition
    let onBack: () -> Void
    let onEnterHumay: () -> Void

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    private var firstName: String {
        String(displayName.split(whereSeparator: \.isWhitespace).first ?? "")
    }

    private var resolvedBirthDetails: BirthDetails {
        birthDetails ?? birthDate.birthDetails
    }

    private var bigThree: BigThree? {
        BigThreeSyncHelper.compute(birth: resolvedBirthDetails)
    }

    private var sunSign: WesternZodiacSign? {
        if let bt = bigThree, case .available(let pos) = bt.sun { return pos.sign }
        return SunSignCalendar.westernSunSign(month: birthDate.month, day: birthDate.day)
    }

    private var headlineTitle: String {
        if firstName.isEmpty {
            return "Your starting profile is ready"
        }
        return "\(firstName), meet your Big Three."
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
                stepLabel: "06 · Your reveal",
                progressIndex: 6,
                onBack: onBack
            )

            OnboardingTitleBlock(
                title: headlineTitle,
                supporting: "Honest, deterministic — and yours to edit anytime.",
                hero: false
            )

            if let bt = bigThree {
                BigThreePreviewCard(bigThree: bt)
                    .accessibilityIdentifier("onboarding.profileReveal.bigThree")
            } else if let sunSign {
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
                stepLabel: "06 · Your reveal",
                progressIndex: 6,
                onBack: onBack
            )

            OnboardingTitleBlock(
                title: headlineTitle,
                supporting: "Honest, deterministic — and yours to edit anytime.",
                hero: false
            )

            HStack(alignment: .top, spacing: HumaySpacing.extraExtraLarge) {
                VStack(alignment: .leading, spacing: metrics.sectionSpacing) {
                    if let bt = bigThree {
                        BigThreePreviewCard(bigThree: bt)
                    } else if let sunSign {
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
                    label: "Birth time",
                    value: birthTimeLabel
                )
                ProfileFactRow(
                    label: "Birth place",
                    value: birthPlaceLabel
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
                        Text("You can edit this anytime")
                            .font(HumayTypography.bodyEmphasized)

                        Text("Birth Details lives in You → Settings. No reinstall needed.")
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

    private var birthTimeLabel: String {
        switch resolvedBirthDetails.time {
        case .exact(let m): Self.formatMinutes(m) + " · Exact"
        case .approximate(let m, let t): "around \(Self.formatMinutes(m)) · ±\(t) min"
        case .unknown: "Not provided"
        }
    }

    private var birthPlaceLabel: String {
        resolvedBirthDetails.place.name ?? "Not provided"
    }

    private static func formatMinutes(_ minutes: Int) -> String {
        let h = minutes / 60
        let m = minutes % 60
        let comps = DateComponents(hour: h, minute: m)
        if let date = Calendar(identifier: .gregorian).date(from: comps) {
            return date.formatted(.dateTime.hour().minute().locale(.current))
        }
        return String(format: "%02d:%02d", h, m)
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

/// Honest Big Three preview for onboarding — reuses terminal presentation conventions.
private struct BigThreePreviewCard: View {
    let bigThree: BigThree

    var body: some View {
        VStack(alignment: .leading, spacing: HumaySpacing.medium) {
            HumayKickerLabel(text: "Your big three — preview")
            VStack(spacing: HumaySpacing.small) {
                sunRow
                moonRow
                risingRow
            }
        }
        .padding(HumaySpacing.extraLarge)
        .background(Color.humaySurface, in: RoundedRectangle(cornerRadius: HumayRadius.feature))
        .overlay { RoundedRectangle(cornerRadius: HumayRadius.feature).strokeBorder(Color.humayHairline) }
    }

    @ViewBuilder
    private var sunRow: some View {
        switch bigThree.sun {
        case .available(let pos):
            PreviewRow(icon: "sun.max.fill", tint: .humaySolarGold, title: "Sun · \(pos.sign.displayName)", subtitle: pos.sign.humayTagline)
        case .ambiguous(let opts):
            let names = opts.map(\.sign.displayName).joined(separator: " or ")
            PreviewRow(icon: "sun.max", tint: .humaySolarGold, title: "Sun · \(names)", subtitle: "Could be either — on a cusp")
        case .unavailable:
            PreviewRow(icon: "sun.max", tint: .humayTextSecondary, title: "Sun · —", subtitle: "Add birth date")
        }
    }

    @ViewBuilder
    private var moonRow: some View {
        switch bigThree.moon {
        case .available(let pos):
            PreviewRow(icon: "moon.fill", tint: .humayLavender, title: "Moon · \(pos.sign.displayName)", subtitle: pos.sign.humayTagline)
        case .ambiguous(let opts):
            let names = opts.map(\.sign.displayName).joined(separator: " or ")
            PreviewRow(icon: "moon", tint: .humayLavender, title: "Moon · \(names)", subtitle: "Ambiguous without tighter time — Humay won't guess")
        case .unavailable(let reason):
            let tease = reason == .missingBirthPlace ? "Add birth place for Moon" : "Birth time needed"
            PreviewRow(icon: "moon.zzz", tint: .humayTextSecondary, title: "Moon · —", subtitle: tease)
        }
    }

    @ViewBuilder
    private var risingRow: some View {
        switch bigThree.rising {
        case .available(let pos):
            PreviewRow(icon: "arrow.up.right.circle.fill", tint: .humayCoral, title: "Rising · \(pos.sign.displayName)", subtitle: pos.sign.humayTagline)
        case .ambiguous:
            PreviewRow(icon: "arrow.up.right.circle", tint: .humayTextSecondary, title: "Rising · Birth time needed", subtitle: "Needs exact minutes + coordinates")
        case .unavailable:
            PreviewRow(icon: "arrow.up.right.circle", tint: .humayTextSecondary, title: "Rising · Birth time needed", subtitle: "Needs exact minutes + coordinates")
        }
    }
}

private struct PreviewRow: View {
    let icon: String
    let tint: Color
    let title: String
    let subtitle: String

    var body: some View {
        HStack(spacing: HumaySpacing.medium) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(tint)
                .frame(width: 32, height: 32)
                .background(tint.opacity(0.14), in: Circle())
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(HumayTypography.bodyEmphasized)
                Text(subtitle).font(HumayTypography.caption).foregroundStyle(Color.humayTextSecondary).fixedSize(horizontal: false, vertical: true)
            }
            Spacer()
        }
        .accessibilityElement(children: .combine)
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
        displayName: "Ava",
        birthDetails: BirthDetails(year: 1994, month: 3, day: 14, time: .exact(minutesFromMidnight: 17*60+5), place: .known(name: "Tehran, Iran", latitude: 35.6892, longitude: 51.3890, timeZoneIdentifier: "Asia/Tehran")),
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
