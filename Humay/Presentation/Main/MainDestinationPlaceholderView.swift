import SwiftUI

struct MainDestinationPlaceholderView: View {
    let destination: MainDestination
    let profileName: String
    let openProfile: () -> Void

    var body: some View {
        GeometryReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: HumaySpacing.extraExtraLarge) {
                    D2WordmarkHeader(
                        title: title,
                        profileName: profileName,
                        profileAction: openProfile
                    )

                    D2UnavailableState(
                        symbol: symbol,
                        title: "\(title) is waiting in the wings",
                        detail: detail
                    )
                    .frame(maxWidth: HumayContentWidth.form.rawValue)
                    .frame(maxWidth: .infinity)
                }
                .frame(maxWidth: HumayContentWidth.expanded.rawValue)
                .frame(maxWidth: .infinity, alignment: .top)
                .padding(.horizontal, HumayLayout.screenGutter(for: proxy.size.width))
                .padding(.vertical, HumaySpacing.large)
            }
        }
        .background(Color.humayGround.ignoresSafeArea())
        .foregroundStyle(Color.humayTextPrimary)
        .navigationBarHidden(true)
    }

    private var title: String {
        switch destination {
        case .sky: "Sky"
        case .chart: "Chart"
        case .ask: "Ask"
        case .today: "Today"
        case .circle: "Circle"
        }
    }

    private var symbol: String {
        switch destination {
        case .sky: "sparkles"
        case .chart: "circle.hexagongrid"
        case .ask: "bubble.left.and.text.bubble.right"
        case .today: "sun.max"
        case .circle: "person.2"
        }
    }

    private var detail: String {
        switch destination {
        case .sky: "Sky feature UI belongs to D3 and is intentionally not designed in this phase."
        case .chart: "Chart feature UI belongs to D4 and remains intentionally minimal here."
        case .ask: "Ask feature UI belongs to D5 and remains intentionally minimal here."
        case .today, .circle: "This destination is implemented by D2."
        }
    }
}
