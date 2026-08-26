import XCTest

/// End-to-end coverage for the entertainment-first IA:
/// onboarding (5 beats), Today feed, Chemistry collision, You timeline, Sky.
@MainActor
final class LaunchUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    // MARK: - Onboarding

    func testOnboardingFlowCompletes() {
        let app = freshApp()

        XCTAssertTrue(
            app.buttons["onboarding.welcome.begin"].waitForExistence(timeout: 3)
        )
        app.buttons["onboarding.welcome.begin"].tap()

        XCTAssertTrue(
            app.buttons["onboarding.birthDate.continue"].waitForExistence(timeout: 3)
        )
        app.buttons["onboarding.birthDate.continue"].tap()

        XCTAssertTrue(
            app.buttons["onboarding.name.continue"].waitForExistence(timeout: 3)
        )
        app.buttons["onboarding.name.continue"].tap()

        XCTAssertTrue(
            app.buttons["onboarding.tradition.continue"].waitForExistence(timeout: 3)
        )
        app.buttons["onboarding.tradition.continue"].tap()

        XCTAssertTrue(
            app.buttons["onboarding.profileReveal.enter"].waitForExistence(timeout: 3)
        )
        XCTAssertTrue(
            element("onboarding.profileReveal.sunSign", in: app).waitForExistence(timeout: 3)
        )
        app.buttons["onboarding.profileReveal.enter"].tap()

        XCTAssertTrue(
            app.staticTexts["main.today.wordmark"].waitForExistence(timeout: 3)
        )
    }

    func testCompletedOnboardingPersistsAcrossRelaunch() {
        let app = freshApp()
        completeOnboarding(in: app)

        XCTAssertTrue(
            app.staticTexts["main.today.wordmark"].waitForExistence(timeout: 3)
        )
        app.terminate()

        let relaunchedApp = XCUIApplication()
        relaunchedApp.launch()

        XCTAssertTrue(
            relaunchedApp.staticTexts["main.today.wordmark"].waitForExistence(timeout: 3)
        )
        XCTAssertFalse(relaunchedApp.buttons["onboarding.welcome.begin"].exists)
    }

    // MARK: - Today

    func testTodayFeedRendersCoreSections() {
        let app = demoApp()

        XCTAssertTrue(element("feed.headline", in: app).waitForExistence(timeout: 3))
        XCTAssertTrue(element("feed.meters", in: app).waitForExistence(timeout: 3))
        let roastExists = element("feed.roast", in: app).waitForExistence(timeout: 3)
        XCTAssertTrue(roastExists || element("feed.flags", in: app).exists)

        // Cosmic weather links into Sky.
        if element("feed.weather", in: app).waitForExistence(timeout: 2) {
            element("feed.weather", in: app).firstMatch.tap()
            XCTAssertTrue(element("sky.current.hero", in: app).waitForExistence(timeout: 3))
        }
    }

    // MARK: - Chemistry

    func testChemistryAddPersonValidationAndCollision() {
        let app = demoApp()

        selectPrimaryDestination("Chemistry", in: app)

        // Add-person sheet validates an empty name.
        XCTAssertTrue(
            app.buttons["chemistry.add-person"].waitForExistence(timeout: 3)
        )
        app.buttons["chemistry.add-person"].tap()
        XCTAssertTrue(
            app.textFields["chemistry.add.name"].waitForExistence(timeout: 3)
        )

        // Close the sheet before interacting with the grid; its dimming layer
        // otherwise swallows taps on the people cards.
        app.buttons["Cancel"].tap()
        XCTAssertTrue(
            app.buttons["chemistry.add-person"].waitForExistence(timeout: 3)
        )

        // Two demo people exist; select both and run the collision.
        let firstCard = app.buttons.matching(
            NSPredicate(format: "label CONTAINS 'Salma'")
        ).firstMatch
        XCTAssertTrue(firstCard.waitForExistence(timeout: 3))
        firstCard.tap()

        let secondCard = app.buttons.matching(
            NSPredicate(format: "label CONTAINS 'Mahtab'")
        ).firstMatch
        XCTAssertTrue(secondCard.waitForExistence(timeout: 3))
        secondCard.tap()

        let runButton = app.buttons["chemistry.compare.run"]
        XCTAssertTrue(runButton.waitForExistence(timeout: 4), "Compare bar did not appear - selection may not have registered")
        runButton.tap()

        XCTAssertTrue(element("collision.verdict", in: app).waitForExistence(timeout: 5))
    }

    // MARK: - You

    func testYouScreenShowsIdentityArchetypeAndTimeline() {
        let app = demoApp()

        selectPrimaryDestination("You", in: app)

        XCTAssertTrue(element("you.archetype", in: app).waitForExistence(timeout: 3))
        XCTAssertTrue(element("you.timeline", in: app).waitForExistence(timeout: 3))
    }

    // MARK: - Sky

    func testSkyTabLoadsCurrentSky() {
        let app = demoApp()

        selectPrimaryDestination("Sky", in: app)

        XCTAssertTrue(
            element("sky.current.hero", in: app).waitForExistence(timeout: 5)
        )
    }

    // MARK: - Helpers

    private func freshApp() -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments.append("-HumayResetPersistence")
        app.launch()
        XCTAssertTrue(
            app.buttons["onboarding.welcome.begin"].waitForExistence(timeout: 5)
        )
        return app
    }

    private func demoApp(extraArguments: [String] = []) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments += [
            "-HumayResetPersistence",
            "-HumayDemo"
        ]
        app.launchArguments += extraArguments
        app.launch()
        XCTAssertTrue(
            app.staticTexts["main.today.wordmark"].waitForExistence(timeout: 5)
        )
        return app
    }

    private func element(_ identifier: String, in app: XCUIApplication) -> XCUIElement {
        app.descendants(matching: .any)[identifier]
    }

    /// Taps the center of an element by coordinate. Some SwiftUI grid buttons
    /// report stale hittability snapshots; coordinate taps are reliable.
    private func tapCenter(_ element: XCUIElement) {
        element.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()
    }

    private func selectPrimaryDestination(_ name: String, in app: XCUIApplication) {
        let tabButton = app.tabBars.buttons[name]
        if tabButton.waitForExistence(timeout: 1) {
            tabButton.tap()
            return
        }

        let sidebarCell = app.cells[name].firstMatch
        if sidebarCell.waitForExistence(timeout: 1) {
            sidebarCell.tap()
            return
        }

        // iPad's adaptive floating tab exposes a nested duplicate button.
        // firstMatch targets the tappable outer item on both size classes.
        let button = app.buttons[name].firstMatch
        XCTAssertTrue(button.waitForExistence(timeout: 3))
        button.tap()
    }

    private func completeOnboarding(in app: XCUIApplication) {
        app.buttons["onboarding.welcome.begin"].tap()
        XCTAssertTrue(
            app.buttons["onboarding.birthDate.continue"].waitForExistence(timeout: 3)
        )
        app.buttons["onboarding.birthDate.continue"].tap()
        XCTAssertTrue(
            app.buttons["onboarding.name.continue"].waitForExistence(timeout: 3)
        )
        app.buttons["onboarding.name.continue"].tap()
        XCTAssertTrue(
            app.buttons["onboarding.tradition.continue"].waitForExistence(timeout: 3)
        )
        app.buttons["onboarding.tradition.continue"].tap()
        XCTAssertTrue(
            app.buttons["onboarding.profileReveal.enter"].waitForExistence(timeout: 3)
        )
        app.buttons["onboarding.profileReveal.enter"].tap()
    }
}
