import SwiftUI

/// A one-pixel rule.
///
/// The design draws with lines rather than boxes, so this does a lot of the work that
/// borders and cards would do elsewhere. One device pixel, not one point — at 3x a 1pt
/// line is noticeably heavier than the design intends.
struct HairlineRule: View {
    enum Weight {
        case hairline
        /// Reserved for the single sanctioned emphasis case.
        case emphasis
    }

    var weight: Weight = .hairline
    var color: Color?

    @Environment(\.humayTheme) private var theme
    @Environment(\.displayScale) private var displayScale

    var body: some View {
        Rectangle()
            .fill(color ?? (weight == .emphasis ? theme.colors.hairlineStrong : theme.colors.hairline))
            .frame(height: thickness)
            .accessibilityHidden(true)
    }

    private var thickness: CGFloat {
        switch weight {
        case .hairline: 1 / max(displayScale, 1)
        case .emphasis: HumayBorder.emphasis / max(displayScale, 1) * 2
        }
    }
}

/// A small uppercase label in mono, used above a section or beside a fact.
struct MonoKicker: View {
    let text: String
    var color: Color?

    @Environment(\.humayTheme) private var theme

    var body: some View {
        Text(text.uppercased())
            .humayFont(.monoKicker)
            .foregroundStyle(color ?? theme.colors.textLabel)
    }
}

/// A technical fact line: a degree, a coordinate, a timestamp.
struct MonoFact: View {
    let text: String
    var emphasised: Bool = false

    @Environment(\.humayTheme) private var theme

    var body: some View {
        Text(text)
            .humayFont(.monoFact)
            .monospacedDigit()
            .foregroundStyle(emphasised ? theme.colors.accentText : theme.colors.textTertiary)
    }
}

/// Marks the tier a piece of content belongs to.
///
/// Under the all-paper surface model this badge and the hairline beneath it carry the
/// distinction that a dark ground used to carry, so it needs to be legible without
/// being loud.
///
/// Only the precise tier is outlined. General is the ordinary state of nearly every
/// screen, so boxing it added a border on almost every surface in the application while
/// distinguishing nothing — the mono kicker alone says it, and the outline is left to
/// mean something.
struct TierBadge: View {
    let tier: PrecisionTier

    @Environment(\.humayTheme) private var theme

    var body: some View {
        Text(tier.badgeLabel.uppercased())
            .humayFont(.monoKicker)
            .foregroundStyle(tier == .precise ? theme.colors.accentText : theme.colors.textLabel)
            .padding(.horizontal, tier == .precise ? HumaySpacing.xs : 0)
            .padding(.vertical, tier == .precise ? 3 : 0)
            .overlay(
                Rectangle()
                    .stroke(
                        tier == .precise ? theme.colors.hairlineAccent : .clear,
                        lineWidth: HumayBorder.hairline
                    )
            )
            .accessibilityLabel("\(tier.badgeLabel) reading")
    }
}

/// An astrological mark with a spoken name.
///
/// Every glyph in the application goes through here. Read raw, VoiceOver announces
/// "pisces symbol" or, worse, nothing — so the spoken name is a required parameter
/// rather than an optional refinement.
struct GlyphLabel: View {
    let glyph: String
    let spokenName: String
    var role: HumayTypeRole = .titleM
    var color: Color?

    @Environment(\.humayTheme) private var theme

    var body: some View {
        Text(glyph)
            .humayFont(role)
            .foregroundStyle(color ?? theme.colors.textPrimary)
            .accessibilityLabel(spokenName)
    }
}

/// The Humay mark: two circles of equal radius, one occulting the other.
///
/// Drawn rather than shipped as an image so it stays crisp at every size and so the
/// geometry stays in the codebase where it can be read. Fixed orientation with the lit
/// limb at the left — the component takes no rotation parameter, deliberately.
struct OccultationMark: View {
    var size: CGFloat = 24

    @Environment(\.humayTheme) private var theme

    private static let minimumSize: CGFloat = 20

    var body: some View {
        let resolved = max(size, Self.minimumSize)
        Canvas { context, canvasSize in
            let scale = canvasSize.width / 100
            let radius = 38 * scale
            let centre = CGPoint(x: canvasSize.width / 2, y: canvasSize.height / 2)

            let disc = Path(ellipseIn: CGRect(
                x: centre.x - radius,
                y: centre.y - radius,
                width: radius * 2,
                height: radius * 2
            ))
            context.fill(disc, with: .color(theme.colors.inverseBackground))

            // The lit crescent is a fill at full strength, never a stroke or a glow.
            let occulting = Path(ellipseIn: CGRect(
                x: centre.x - radius + 0.29 * radius,
                y: centre.y - radius,
                width: radius * 2,
                height: radius * 2
            ))
            var crescent = disc
            crescent.addPath(occulting)
            context.fill(crescent, with: .color(theme.colors.accentMark), style: FillStyle(eoFill: true))
        }
        .frame(width: resolved, height: resolved)
        .accessibilityHidden(true)
    }
}

/// A section heading: a mono kicker over a rule.
///
/// The glossary trigger belongs *inside* the header rather than beside it. Put outside,
/// it shortened the rule to whatever width was left over, so the sections carrying a term
/// definition ruled to a different length than the ones that did not — a difference of a
/// few points that reads, across a chart screen, as carelessness.
struct SectionHeader: View {
    let title: String
    var trailing: String?
    var glossaryTerm: (id: String, name: String)?
    var onGlossaryTerm: ((String) -> Void)?

    var body: some View {
        VStack(alignment: .leading, spacing: HumaySpacing.xs) {
            HStack(alignment: .firstTextBaseline, spacing: 0) {
                // The trigger stays a separate button rather than being merged into the
                // heading: folding a control into a header is how a definition becomes
                // unreachable with VoiceOver.
                MonoKicker(text: title)
                    .accessibilityAddTraits(.isHeader)

                if let glossaryTerm, let onGlossaryTerm {
                    InfoTrigger(
                        termID: glossaryTerm.id,
                        termName: glossaryTerm.name,
                        action: onGlossaryTerm
                    )
                }

                Spacer(minLength: HumaySpacing.s)

                if let trailing {
                    MonoFact(text: trailing)
                        .accessibilityLabel("\(title): \(trailing)")
                }
            }
            HairlineRule()
        }
    }
}

/// Marks content that came from a fixture.
///
/// Development builds only. Its whole job is to make a screenshot of sample content
/// impossible to mistake for a real reading.
struct SampleContentMarker: View {
    let provenance: ContentProvenance

    @Environment(\.humayTheme) private var theme

    var body: some View {
        if HumayBuild.showsSampleContentMarker, provenance.isMock {
            Text("SAMPLE")
                .humayFont(.monoKicker)
                .foregroundStyle(theme.colors.roast.opacity(0.8))
                .accessibilityLabel("Sample content, not calculated")
        }
    }
}
