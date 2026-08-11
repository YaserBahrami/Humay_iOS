import SwiftUI

/// The people who matter, and how today sits between you.
struct CircleView: View {
    @Environment(AppEnvironment.self) private var environment
    @Environment(AppRouter.self) private var router
    @Environment(\.humayTheme) private var theme

    @State private var isAddingPerson = false

    var body: some View {
        ScreenScaffold(title: "Circle") {
            VStack(alignment: .leading, spacing: HumaySpacing.l) {
                if environment.people.isEmpty {
                    EmptyStateView(
                        title: "Nobody here yet",
                        message: "Add someone and Humay can read the two of you together. A birth date is enough to start.",
                        actionTitle: "Add someone"
                    ) { isAddingPerson = true }
                } else {
                    CircleOrbitView(people: environment.people)
                        .padding(.vertical, HumaySpacing.s)

                    VStack(spacing: 0) {
                        SectionHeader(title: "Your people", trailing: "\(environment.people.count)")
                        ForEach(environment.people) { person in
                            PersonRow(person: person) {
                                router.push(.person(person.id), on: .circle)
                            }
                            HairlineRule()
                        }
                    }
                }

                Button {
                    isAddingPerson = true
                } label: {
                    HStack(spacing: HumaySpacing.xs) {
                        Image(systemName: "plus")
                            .font(.system(size: 12, weight: .medium))
                        Text("Add person")
                    }
                }
                .buttonStyle(.humayOutline)

                quickCheck
            }
        }
        .sheet(isPresented: $isAddingPerson) {
            AddPersonSheet()
        }
    }

    @ViewBuilder
    private var quickCheck: some View {
        VStack(alignment: .leading, spacing: HumaySpacing.s) {
            SectionHeader(title: "Quick check")
            Text("Compare any two signs without saving anyone.")
                .humayFont(.bodySmall)
                .foregroundStyle(theme.colors.textSecondary)
            Button("Compare two signs") {
                router.push(.quickCheck, on: .circle)
            }
            .buttonStyle(.humayQuiet)
        }
        .padding(.top, HumaySpacing.s)
    }
}

/// A person, as a row.
struct PersonRow: View {
    let person: CirclePerson
    let action: () -> Void

    @Environment(\.humayTheme) private var theme
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @ScaledMetric(relativeTo: .callout) private var initialsSide: CGFloat = 36

    var body: some View {
        Button(action: action) {
            HStack(spacing: HumaySpacing.s) {
                // Initials in a hairline square. No photographs — the people in here
                // did not agree to be in an address book.
                Text(person.initials)
                    .humayFont(.callout)
                    .foregroundStyle(theme.colors.textSecondary)
                    .frame(width: initialsSide, height: initialsSide)
                    .overlay(
                        Rectangle().stroke(
                            person.role.isCore ? theme.colors.hairlineAccent : theme.colors.hairline,
                            lineWidth: person.role.isCore ? HumayBorder.emphasis : HumayBorder.hairline
                        )
                    )
                    .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: 1) {
                    Text(person.name)
                        .humayFont(.titleS)
                        .foregroundStyle(theme.colors.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)
                    Text("\(MockAstrology.sunSign(for: person.birth).spokenName) · \(person.role.displayName)")
                        .humayFont(.callout)
                        .foregroundStyle(theme.colors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                    if !person.birth.time.isKnown, dynamicTypeSize.isAccessibilitySize {
                        MonoFact(text: "DATE ONLY")
                    }
                }

                Spacer(minLength: HumaySpacing.xs)

                if !person.birth.time.isKnown, !dynamicTypeSize.isAccessibilitySize {
                    MonoFact(text: "DATE ONLY")
                }

                DisclosureChevron()
            }
            .frame(minHeight: HumayHitTarget.minimum)
            .padding(.vertical, HumaySpacing.xs)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityLabel)
        .accessibilityAddTraits(.isButton)
    }

    private var accessibilityLabel: String {
        var parts = [
            person.name,
            "\(MockAstrology.sunSign(for: person.birth).spokenName) sun",
            person.role.displayName,
        ]
        if !person.birth.time.isKnown { parts.append("birth date only") }
        return parts.joined(separator: ", ")
    }
}

/// The Circle, drawn.
///
/// You at the centre, everyone else on one ring. The partner spoke is drawn at the
/// heavier weight — the single sanctioned emphasis case in the design.
///
/// The ring is sized from the container rather than from a fixed number, so a larger
/// screen later gets a larger drawing rather than a stretched one. The height scales with
/// the reader's text size, because the initials and role labels sitting on the ring grow
/// with it; at the accessibility sizes the drawing is dropped entirely and the list below
/// carries the whole of its meaning, which is what its accessible representation already
/// said it did.
struct CircleOrbitView: View {
    let people: [CirclePerson]

    @Environment(\.humayTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @ScaledMetric(relativeTo: .body) private var height: CGFloat = 230
    @State private var drawn = false

    var body: some View {
        if !dynamicTypeSize.isAccessibilitySize {
            drawing.frame(height: height)
        }
    }

    private var drawing: some View {
        GeometryReader { proxy in
            let size = min(proxy.size.width, proxy.size.height)
            let centre = CGPoint(x: proxy.size.width / 2, y: proxy.size.height / 2)
            let radius = size * 0.36

            ZStack {
                Canvas { context, _ in
                    // The ring.
                    let ring = Path(ellipseIn: CGRect(
                        x: centre.x - radius,
                        y: centre.y - radius,
                        width: radius * 2,
                        height: radius * 2
                    ))
                    context.stroke(ring, with: .color(theme.colors.hairline), lineWidth: 1)

                    // A spoke to each person.
                    for (index, person) in people.enumerated() {
                        let angle = angle(for: index)
                        let point = position(centre: centre, radius: radius, angle: angle)
                        var spoke = Path()
                        spoke.move(to: centre)
                        spoke.addLine(to: point)
                        context.stroke(
                            spoke,
                            with: .color(person.role.isCore ? theme.colors.hairlineAccent : theme.colors.hairline),
                            lineWidth: person.role.isCore ? HumayBorder.emphasis : HumayBorder.hairline
                        )
                    }
                }
                .opacity(drawn || reduceMotion ? 1 : 0)

                // You.
                Circle()
                    .fill(theme.colors.accentMark)
                    .frame(width: 7, height: 7)
                    .position(centre)

                ForEach(Array(people.enumerated()), id: \.element.id) { index, person in
                    let point = position(centre: centre, radius: radius, angle: angle(for: index))
                    VStack(spacing: 2) {
                        Text(person.initials)
                            .humayFont(.callout)
                            .foregroundStyle(theme.colors.textPrimary)
                        Text(person.role.displayName)
                            .humayFont(.monoKicker)
                            .foregroundStyle(theme.colors.textLabel)
                    }
                    .padding(.horizontal, 6)
                    .background(theme.colors.background)
                    .position(point)
                }
            }
            .onAppear {
                withAnimation(reduceMotion ? HumayMotion.reducedCrossfade : HumayMotion.draw) {
                    drawn = true
                }
            }
        }
        // The drawing is decorative; the list below carries the same information in a
        // form VoiceOver can navigate, so this is replaced rather than described.
        .accessibilityRepresentation {
            VStack {
                Text("Your circle, \(people.count) people")
                ForEach(people) { person in
                    Text("\(person.name), \(person.role.displayName)")
                }
            }
        }
    }

    private func angle(for index: Int) -> Angle {
        // Starts at the top and spreads evenly.
        .degrees(-90 + Double(index) * (360.0 / Double(max(people.count, 1))))
    }

    private func position(centre: CGPoint, radius: CGFloat, angle: Angle) -> CGPoint {
        CGPoint(
            x: centre.x + radius * cos(angle.radians),
            y: centre.y + radius * sin(angle.radians)
        )
    }
}

#Preview {
    NavigationStack { CircleView() }
        .environment(AppEnvironment.preview())
        .environment(AppRouter())
}
