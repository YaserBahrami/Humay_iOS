import SwiftUI

/// The compatibility collision: two people fly together, collide, and the
/// verdict bursts out. Deliberately theatrical — this is a chaos moment.
struct CompatibilityCollisionView: View {
    let first: ConnectionPerson
    let second: ConnectionPerson

    @Environment(AppEnvironment.self) private var environment
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var phase: Phase = .approaching
    @State private var showDetail = false
    @State private var shareActivity: ShareActivity?
    @State private var verdict: CompatibilityVerdict?
    @State private var showsAstrologyBasis = false

    enum Phase {
        case approaching
        case collided
    }

    var body: some View {
        Group {
            if let verdict {
                content(verdict)
            } else {
                Color.humayGround
                    .ignoresSafeArea()
                    .task { makeVerdict() }
            }
        }
        .foregroundStyle(Color.humayTextPrimary)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Close") { dismiss() }
            }
        }
        .sheet(item: $shareActivity) { activity in
            ShareSheet(activity: activity)
        }
    }

    private func makeVerdict() {
        verdict = HumayContentEngine.compatibility(
            first: first,
            second: second,
            mode: environment.settings.personalityMode
        )
        runSequence()
    }

    // MARK: - Layout

    private func content(_ verdict: CompatibilityVerdict) -> some View {
        GeometryReader { proxy in
            ZStack {
                Color.humayGround.ignoresSafeArea()

                VStack(spacing: HumaySpacing.extraExtraLarge) {
                    header
                        .padding(.top, HumaySpacing.extraLarge)

                    Spacer()

                    collisionStage(width: proxy.size.width)

                    Spacer()

                    if showDetail {
                        verdictSection(verdict)
                            .accessibilityIdentifier("collision.verdict")
                            .transition(reduceMotion ? .opacity : .scale(scale: 0.92).combined(with: .opacity))
                    }
                }
                .frame(maxWidth: HumayContentWidth.expanded.rawValue)
            }
        }
    }

    // MARK: - Choreography

    private func runSequence() {
        guard !reduceMotion else {
            phase = .collided
            showDetail = true
            return
        }

        Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(450))
            withAnimation(HumayMotion.bouncy) {
                phase = .collided
            }
            try? await Task.sleep(for: .milliseconds(320))
            HumayHaptics.collision()
            withAnimation(HumayMotion.gentle.delay(0.1)) {
                showDetail = true
            }
        }
    }

    private func replay() {
        showDetail = false
        phase = .approaching

        if reduceMotion {
            phase = .collided
            showDetail = true
            return
        }

        Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(500))
            withAnimation(HumayMotion.bouncy) {
                phase = .collided
            }
            try? await Task.sleep(for: .milliseconds(320))
            HumayHaptics.collision()
            withAnimation(HumayMotion.gentle) {
                showDetail = true
            }
        }
    }

    /// Two medallions that travel from opposite edges into an overlapping center.
    private func collisionStage(width: CGFloat) -> some View {
        let travel = max(width * 0.28, 90)

        return ZStack {
            Circle()
                .fill(RadialGradient(colors: [Color.humayCoral.opacity(0.35), .clear], center: .center, startRadius: 10, endRadius: 130))
                .frame(width: 260, height: 260)
                .opacity(phase == .collided ? 1 : 0)
                .accessibilityHidden(true)

            HStack(spacing: -34) {
                PersonMedallion(person: first, accent: .coral, size: 104)
                PersonMedallion(person: second, accent: .lavender, size: 104)
            }
            .offset(x: phase == .approaching ? travel : 0)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(first.name) and \(second.name)")
    }

    private var header: some View {
        VStack(spacing: HumaySpacing.extraSmall) {
            Text("CHEMISTRY REPORT")
                .font(HumayTypography.utility)
                .tracking(1.4)
                .foregroundStyle(Color.humayCoral)

            Text("\(first.name) + \(second.name)")
                .font(HumayTypography.editorialTitle)
                .multilineTextAlignment(.center)
        }
    }

    private func verdictSection(_ verdict: CompatibilityVerdict) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: HumaySpacing.large) {
                headlineBlock(verdict)

                meterBlock(verdict)

                verdictLinesBlock(verdict)

                astrologyDisclosure(verdict)

                actions(verdict)
            }
            .padding(.horizontal, HumaySpacing.extraLarge)
            .padding(.bottom, HumaySpacing.extraLarge)
        }
        .scrollIndicators(.hidden)
    }

    private func headlineBlock(_ verdict: CompatibilityVerdict) -> some View {
        VStack(alignment: .leading, spacing: HumaySpacing.small) {
            HStack(alignment: .firstTextBaseline, spacing: HumaySpacing.medium) {
                Text("\(verdict.overall)% compatible")
                    .font(HumayTypography.expressiveScore)
                    .foregroundStyle(Color.humayCoral)
                Spacer()
                Button {
                    replay()
                } label: {
                    Label("Again", systemImage: "arrow.counterclockwise")
                        .font(HumayTypography.supportingEmphasized)
                        .frame(minWidth: 44, minHeight: 44)
                }
                .buttonStyle(.humayPressable)
                .accessibilityHint("Runs the collision again")
            }

            Text(verdict.headline)
                .font(HumayTypography.cardTitle)
                .fixedSize(horizontal: false, vertical: true)

            Text(verdict.summary)
                .font(HumayTypography.supporting)
                .foregroundStyle(Color.humayTextSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private func meterBlock(_ verdict: CompatibilityVerdict) -> some View {
        HumaySurface {
            VStack(spacing: HumaySpacing.large) {
                ForEach(verdict.funMetrics) { meter in
                    HumayMeter(meter: meter)
                }
            }
        }
    }

    private func verdictLinesBlock(_ verdict: CompatibilityVerdict) -> some View {
        HumaySurface(padding: HumaySpacing.large) {
            VStack(alignment: .leading, spacing: HumaySpacing.medium) {
                ForEach(verdict.verdictLines) { line in
                    VStack(alignment: .leading, spacing: 2) {
                        Text(line.question)
                            .font(HumayTypography.utility)
                            .textCase(.uppercase)
                            .tracking(1.1)
                            .foregroundStyle(Color.humayTextSecondary)
                        Text(line.answer)
                            .font(HumayTypography.bodyEmphasized)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .accessibilityElement(children: .combine)
                }
            }
        }
    }

    /// Level-3 disclosure: clearly labeled traditional basis, collapsible.
    private func astrologyDisclosure(_ verdict: CompatibilityVerdict) -> some View {
        VStack(alignment: .leading, spacing: HumaySpacing.small) {
            Button {
                withAnimation(HumayMotion.snappy) {
                    showsAstrologyBasis.toggle()
                }
            } label: {
                Label(showsAstrologyBasis ? "Hide the astrology part" : "Why? (the actual astrology)",
                      systemImage: showsAstrologyBasis ? "chevron.down" : "chevron.right")
                    .font(HumayTypography.supportingEmphasized)
                    .foregroundStyle(Color.humayLavender)
                    .frame(minHeight: 44)
            }
            .buttonStyle(.plain)

            if showsAstrologyBasis {
                Text(verdict.astrologyBasis)
                    .font(HumayTypography.supporting)
                    .foregroundStyle(Color.humayTextSecondary)
                    .fixedSize(horizontal: false, vertical: true)
                    .transition(.opacity)
            }
        }
        .accessibilityElement(children: .contain)
    }

    private func actions(_ verdict: CompatibilityVerdict) -> some View {
        Button {
            shareActivity = ShareActivity(
                kind: .compatibility(verdict, firstName: first.name, secondName: second.name)
            )
        } label: {
            Label("Send this to them", systemImage: "paperplane.fill")
                .frame(maxWidth: .infinity)
                .frame(minHeight: HumayMetrics.primaryControlMinimumHeight - 12)
        }
        .buttonStyle(.humayPrimary)
    }
}
