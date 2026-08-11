import XCTest

/// The project defaults to `MainActor` isolation, but `XCTestCase` declares its
/// lifecycle hooks as nonisolated. Declaring the class nonisolated keeps the overrides
/// matching, and individual tests opt back in with `@MainActor` where they drive UI.
nonisolated final class LaunchUITests: XCTestCase {
    override func setUp() {
        continueAfterFailure = false
    }

    @MainActor
    func testAppLaunchesAndShowsTheWordmark() {
        let app = XCUIApplication()
        app.launch()
        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 15))
        XCTAssertTrue(
            app.staticTexts["Humay"].waitForExistence(timeout: 10),
            "The Humay wordmark should be present on the first screen"
        )
    }
}
