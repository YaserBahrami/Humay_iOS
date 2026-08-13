import Foundation

/// App-boundary composition for immutable feature inputs.
/// Development fixtures never cross this boundary in Release.
enum AppFeatureComposition {
    static func makeD2Input(
        arguments: [String] = ProcessInfo.processInfo.arguments
    ) -> D2FeatureInput {
#if DEBUG
        DevelopmentD2Sample.makeInput(arguments: arguments)
#else
        .productionUnavailable
#endif
    }

    static func makeD3Input(
        arguments: [String] = ProcessInfo.processInfo.arguments
    ) -> D3FeatureInput {
#if DEBUG
        DevelopmentD3Sample.makeInput(arguments: arguments)
#else
        .productionUnavailable
#endif
    }
}
