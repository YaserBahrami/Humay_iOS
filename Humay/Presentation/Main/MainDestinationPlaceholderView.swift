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

                    HumaySurface(level: .raised) {
                        VStack(spacing: HumaySpacing.large) {
                            HumayIllustration(name: artworkName)
                                .frame(width: 180, height: 150)

                            Text(headline)
                                .font(HumayTypography.editorialTitle)
                                .multilineTextAlignment(.center)
                                .accessibilityAddTraits(.isHeader)

                            Text(detail)
                                .font(HumayTypography.body)
                                .foregroundStyle(Color.humayTextSecondary)
                                .multilineTextAlignment(.center)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, HumaySpacing.extraLarge)
                    }
                    .frame(maxWidth: HumayContentWidth.form.rawValue)
                    .frame(maxWidth: .infinity)
                }
                .frame(maxWidth: HumayContentWidth.expanded.rawValue)
                .frame(maxWidth: .infinity, alignment: .top)
                .padding(.horizontal, HumayLayout.screenGutter(for: proxy.size.width))
                .padding(.vertical, HumaySpacing.large)
            }
            .scrollIndicators(.hidden)
        }
        .background(Color.humayGround.ignoresSafeArea())
        .foregroundStyle(Color.humayTextPrimary)
        .navigationBarHidden(true)
    }

    private var title: String {
        switch destination {
        case .explore: "Explore"
        case .chart: "Chart"
        case .you: "You"
        case .today: "Today"
        case .connections: "Connections"
        }
    }

    private var artworkName: String {
        switch destination {
        case .explore: "IllustrationCurrentSky"
        case .chart: "IllustrationWesternChart"
        case .you: "IllustrationProfileReveal"
        case .today: "IllustrationCosmicWeather"
        case .connections: "IllustrationTodayTogether"
        }
    }

    private var headline: String {
        switch destination {
        case .explore: "Explore is taking shape"
        case .chart: "Your chart is taking shape"
        case .you: "Your Humay is taking shape"
        case .today: "Today is taking shape"
        case .connections: "Your connections are taking shape"
        }
    }

    private var detail: String {
        switch destination {
        case .explore: "Questions, current sky, calendar, and Ask Humay live here."
        case .chart: "Your chart, placements and system comparisons will live here."
        case .you: "Profile, birth details, saved people, and preferences live here."
        case .today: "Your daily guidance will live here."
        case .connections: "People and compatibility live here."
        }
    }
}
