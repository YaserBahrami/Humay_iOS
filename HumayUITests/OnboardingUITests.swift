import XCTest

/// The project defaults to nonisolated, and `XCUIApplication` wants the main actor, so
/// the tests opt in individually.
nonisolated final class OnboardingUITests: XCTestCase {
    override func setUp() {
        continueAfterFailure = false
    }

    @MainActor
    func testOnboardingReachesToday() {
        let app = launchFresh()

        XCTAssertTrue(
            app.staticTexts["Read the sky.\nSee the reasoning."].waitForExistence(timeout: 10),
            "The welcome beat should be the first thing shown on a fresh install"
        )

        app.buttons["Begin"].tap()
        XCTAssertTrue(app.staticTexts["When were you born?"].waitForExistence(timeout: 5))

        app.buttons["Continue"].tap()
        XCTAssertTrue(app.staticTexts["Which tradition should lead?"].waitForExistence(timeout: 5))

        app.buttons["Continue"].tap()
        XCTAssertTrue(app.buttons["Enter Humay"].waitForExistence(timeout: 5))

        app.buttons["Enter Humay"].tap()

        // All five tabs are present, and Calendar is deliberately not among them.
        for tab in Self.tabs {
            XCTAssertTrue(
                app.tabBars.buttons[tab].waitForExistence(timeout: 10),
                "\(tab) should be a root tab"
            )
        }
        XCTAssertFalse(app.tabBars.buttons["Calendar"].exists, "Calendar belongs inside Sky")
        XCTAssertFalse(app.tabBars.buttons["Settings"].exists, "Settings is reached from the header")
    }

    @MainActor
    func testEveryTabOpens() {
        // Self-sufficient rather than relying on another case having run first: test
        // order is not guaranteed, and the onboarding case resets stored state.
        let app = launchFresh()
        completeOnboarding(in: app)

        for tab in Self.tabs {
            let button = app.tabBars.buttons[tab]
            XCTAssertTrue(button.waitForExistence(timeout: 10), "\(tab) tab should exist")
            button.tap()
            XCTAssertTrue(button.isSelected, "Tapping \(tab) should select it")
        }
    }

    @MainActor
    func testSettingsOpensFromTheHeaderAndCloses() {
        let app = launchFresh()
        completeOnboarding(in: app)

        app.buttons["Profile and settings"].tap()
        XCTAssertTrue(
            app.staticTexts["Profile & settings"].waitForExistence(timeout: 5),
            "The header entry should open the settings cover"
        )

        app.buttons["Close"].tap()
        XCTAssertTrue(
            app.tabBars.buttons["Today"].waitForExistence(timeout: 5),
            "Closing settings should return to the tabs"
        )
    }

    // MARK: - Helpers

    private static let tabs = ["Today", "Circle", "Sky", "Chart", "Ask"]

    @MainActor
    private func launchFresh() -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = ["-humay-reset-state"]
        app.launch()
        return app
    }

    @MainActor
    private func completeOnboarding(in app: XCUIApplication) {
        guard app.buttons["Begin"].waitForExistence(timeout: 10) else {
            XCTFail("Onboarding should start from the welcome beat after a state reset")
            return
        }
        app.buttons["Begin"].tap()
        app.buttons["Continue"].tap()
        app.buttons["Continue"].tap()
        XCTAssertTrue(app.buttons["Enter Humay"].waitForExistence(timeout: 5))
        app.buttons["Enter Humay"].tap()
    }
}
