#if DEBUG
import SwiftUI

/// Preview-only visual harness. It is intentionally not reachable from runtime UI.
private struct HumayDesignSystemShowcase: View {
    private let palette: [(String, Color)] = [
        ("Ground", .humayGround),
        ("Surface", .humaySurface),
        ("Raised", .humayRaisedSurface),
        ("Primary text", .humayTextPrimary),
        ("Secondary text", .humayTextSecondary),
        ("Hairline", .humayHairline),
        ("Coral", .humayCoral),
        ("Lavender", .humayLavender),
        ("Solar gold", .humaySolarGold),
        ("Celestial blue", .humayCelestialBlue),
        ("Sage", .humaySage)
    ]

    var body: some View {
        ScrollView {
            HumayContentColumn(maximum: .readable) {
                VStack(alignment: .leading, spacing: HumaySpacing.extraExtraLarge) {
                    typography
                    colors
                    surfaces
                    actions
                    metrics
                }
                .padding(.vertical, HumaySpacing.extraExtraLarge)
            }
        }
        .background(Color.humayGround.ignoresSafeArea())
        .foregroundStyle(Color.humayTextPrimary)
    }

    private var typography: some View {
        VStack(alignment: .leading, spacing: HumaySpacing.medium) {
            Text("humay")
                .font(HumayTypography.wordmark)
            Text("Soulful Celestial")
                .font(HumayTypography.heroTitle)
            Text("Editorial title")
                .font(HumayTypography.editorialTitle)
            Text("Clear system body supports long-form reading and Dynamic Type.")
                .font(HumayTypography.body)
            Text("14° 27′ · 21:42")
                .font(HumayTypography.technical)
                .foregroundStyle(Color.humayTextSecondary)
        }
    }

    private var colors: some View {
        VStack(alignment: .leading, spacing: HumaySpacing.large) {
            sectionTitle("Semantic palette")

            LazyVGrid(
                columns: [GridItem(.adaptive(minimum: 132), spacing: HumaySpacing.medium)],
                spacing: HumaySpacing.medium
            ) {
                ForEach(palette, id: \.0) { name, color in
                    HStack(spacing: HumaySpacing.small) {
                        Circle()
                            .fill(color)
                            .frame(width: 28, height: 28)
                            .overlay(Circle().stroke(Color.humayHairline))
                            .accessibilityHidden(true)

                        Text(name)
                            .font(HumayTypography.supporting)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
    }

    private var surfaces: some View {
        VStack(alignment: .leading, spacing: HumaySpacing.large) {
            sectionTitle("Surfaces")

            HumayAdaptiveStack {
                HumaySurface {
                    surfaceCopy(title: "Standard", detail: "Quiet surface with a subtle hairline.")
                }

                HumaySurface(level: .raised) {
                    surfaceCopy(title: "Raised", detail: "Tonal hierarchy leads in Dark Mode.")
                }
            }
        }
    }

    private var actions: some View {
        VStack(alignment: .leading, spacing: HumaySpacing.large) {
            sectionTitle("Actions")

            Button("Primary action") {}
                .buttonStyle(.humayPrimary)

            Button("Secondary action") {}
                .buttonStyle(.humaySecondary)

            Button("Disabled action") {}
                .buttonStyle(.humayPrimary)
                .disabled(true)
        }
    }

    private var metrics: some View {
        HumaySurface(level: .raised) {
            HStack(spacing: HumaySpacing.large) {
                Image(systemName: "sparkles")
                    .foregroundStyle(Color.humaySolarGold)
                    .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: HumaySpacing.extraSmall) {
                    Text("Adaptive foundation")
                        .font(HumayTypography.bodyEmphasized)
                    Text("Bounded columns, adaptive stacks, 44 pt minimum targets.")
                        .font(HumayTypography.supporting)
                        .foregroundStyle(Color.humayTextSecondary)
                }
            }
        }
    }

    private func sectionTitle(_ title: String) -> some View {
        Text(title)
            .font(HumayTypography.utility)
            .textCase(.uppercase)
            .foregroundStyle(Color.humayTextSecondary)
    }

    private func surfaceCopy(title: String, detail: String) -> some View {
        VStack(alignment: .leading, spacing: HumaySpacing.small) {
            Text(title)
                .font(HumayTypography.bodyEmphasized)
            Text(detail)
                .font(HumayTypography.supporting)
                .foregroundStyle(Color.humayTextSecondary)
        }
    }
}

#Preview("iPhone Light", traits: .fixedLayout(width: 393, height: 852)) {
    HumayDesignSystemShowcase()
        .preferredColorScheme(.light)
}

#Preview("iPhone Dark", traits: .fixedLayout(width: 393, height: 852)) {
    HumayDesignSystemShowcase()
        .preferredColorScheme(.dark)
}

#Preview("iPad Portrait Light", traits: .fixedLayout(width: 1024, height: 1366)) {
    HumayDesignSystemShowcase()
        .preferredColorScheme(.light)
}

#Preview("iPad Landscape Dark", traits: .fixedLayout(width: 1366, height: 1024)) {
    HumayDesignSystemShowcase()
        .preferredColorScheme(.dark)
}
#endif
