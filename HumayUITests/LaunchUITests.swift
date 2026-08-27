import XCTest

/// End-to-end coverage for the entertainment-first IA:
/// onboarding (7 beats), Today feed, Chemistry collision, You timeline, Sky.
@MainActor
final class LaunchUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    // MARK: - Onboarding

    func testOnboardingFlowCompletes() {
        let app = freshApp()

        XCTAssertTrue(element("onboarding.welcome.begin", in: app).waitForExistence(timeout: 3))
        element("onboarding.welcome.begin", in: app).tap()

        XCTAssertTrue(element("onboarding.birthDate.continue", in: app).waitForExistence(timeout: 3))
        element("onboarding.birthDate.continue", in: app).tap()

        tapBirthTimeContinue(in: app)
        tapBirthPlaceContinue(in: app)

        XCTAssertTrue(element("onboarding.name.continue", in: app).waitForExistence(timeout: 3))
        element("onboarding.name.continue", in: app).tap()

        XCTAssertTrue(element("onboarding.tradition.continue", in: app).waitForExistence(timeout: 3))
        element("onboarding.tradition.continue", in: app).tap()

        XCTAssertTrue(element("onboarding.profileReveal.enter", in: app).waitForExistence(timeout: 3))
        XCTAssertTrue(element("onboarding.profileReveal.bigThree", in: app).waitForExistence(timeout: 3) || element("onboarding.profileReveal.sunSign", in: app).waitForExistence(timeout: 3))
        element("onboarding.profileReveal.enter", in: app).tap()

        XCTAssertTrue(app.staticTexts["main.today.wordmark"].waitForExistence(timeout: 3))
    }

    func testCompletedOnboardingPersistsAcrossRelaunch() {
        let app = freshApp()
        completeOnboarding(in: app)

        XCTAssertTrue(app.staticTexts["main.today.wordmark"].waitForExistence(timeout: 3))
        app.terminate()

        let relaunchedApp = XCUIApplication()
        relaunchedApp.launch()

        XCTAssertTrue(relaunchedApp.staticTexts["main.today.wordmark"].waitForExistence(timeout: 3))
        XCTAssertFalse(relaunchedApp.buttons["onboarding.welcome.begin"].exists)
    }

    // MARK: - Today

    func testTodayFeedRendersCoreSections() {
        let app = demoApp()

        XCTAssertTrue(element("feed.headline", in: app).waitForExistence(timeout: 3))
        XCTAssertTrue(element("feed.meters", in: app).waitForExistence(timeout: 3))
        let roastExists = element("feed.roast", in: app).waitForExistence(timeout: 3)
        XCTAssertTrue(roastExists || element("feed.flags", in: app).exists)

        if element("feed.weather", in: app).waitForExistence(timeout: 2) {
            element("feed.weather", in: app).firstMatch.tap()
            XCTAssertTrue(element("sky.current.hero", in: app).waitForExistence(timeout: 3))
        }
    }

    // MARK: - Chemistry

    func testChemistryAddPersonValidationAndCollision() {
        let app = demoApp()

        selectPrimaryDestination("Chemistry", in: app)

        XCTAssertTrue(app.buttons["chemistry.add-person"].waitForExistence(timeout: 3))
        app.buttons["chemistry.add-person"].tap()
        XCTAssertTrue(app.textFields["chemistry.add.name"].waitForExistence(timeout: 3))

        app.buttons["Cancel"].tap()
        XCTAssertTrue(app.buttons["chemistry.add-person"].waitForExistence(timeout: 3))

        let firstCard = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Salma'")).firstMatch
        XCTAssertTrue(firstCard.waitForExistence(timeout: 3))
        firstCard.tap()

        let secondCard = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Mahtab'")).firstMatch
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

        XCTAssertTrue(element("sky.current.hero", in: app).waitForExistence(timeout: 5))
    }

    // MARK: - Helpers

    private func tapBirthTimeContinue(in app: XCUIApplication) {
        if element("onboarding.birthTime.continue", in: app).waitForExistence(timeout: 5) {
            element("onboarding.birthTime.continue", in: app).tap(); return
        }
        let byLabel = app.buttons["Continue without time"].firstMatch
        if byLabel.waitForExistence(timeout: 2) { byLabel.tap(); return }
        let byLabel2 = app.buttons["Continue"].firstMatch
        if byLabel2.waitForExistence(timeout: 2) { byLabel2.tap(); return }
        XCTFail("Birth time continue not found")
    }

    private func tapBirthPlaceContinue(in app: XCUIApplication) {
        if element("onboarding.birthPlace.continue", in: app).waitForExistence(timeout: 5) {
            element("onboarding.birthPlace.continue", in: app).tap(); return
        }
        for label in ["Continue", "Use this place", "Skip for now"] {
            let btn = app.buttons[label].firstMatch
            if btn.waitForExistence(timeout: 1) { btn.tap(); return }
        }
        XCTFail("Birth place continue not found")
    }

    private func freshApp() -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments.append("-HumayResetPersistence")
        app.launch()
        XCTAssertTrue(element("onboarding.welcome.begin", in: app).waitForExistence(timeout: 5))
        return app
    }

    private func demoApp(extraArguments: [String] = []) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments += ["-HumayResetPersistence", "-HumayDemo"]
        app.launchArguments += extraArguments
        app.launch()
        XCTAssertTrue(app.staticTexts["main.today.wordmark"].waitForExistence(timeout: 5))
        return app
    }

    private func element(_ identifier: String, in app: XCUIApplication) -> XCUIElement {
        app.descendants(matching: .any)[identifier]
    }

    private func tapCenter(_ element: XCUIElement) {
        element.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()
    }

    private func selectPrimaryDestination(_ name: String, in app: XCUIApplication) {
        let tabButton = app.tabBars.buttons[name]
        if tabButton.waitForExistence(timeout: 1) { tabButton.tap(); return }
        let sidebarCell = app.cells[name].firstMatch
        if sidebarCell.waitForExistence(timeout: 1) { sidebarCell.tap(); return }
        let button = app.buttons[name].firstMatch
        XCTAssertTrue(button.waitForExistence(timeout: 3)); button.tap()
    }

    private func completeOnboarding(in app: XCUIApplication) {
        element("onboarding.welcome.begin", in: app).tap()
        XCTAssertTrue(element("onboarding.birthDate.continue", in: app).waitForExistence(timeout: 3))
        element("onboarding.birthDate.continue", in: app).tap()
        tapBirthTimeContinue(in: app)
        tapBirthPlaceContinue(in: app)
        XCTAssertTrue(element("onboarding.name.continue", in: app).waitForExistence(timeout: 3))
        element("onboarding.name.continue", in: app).tap()
        XCTAssertTrue(element("onboarding.tradition.continue", in: app).waitForExistence(timeout: 3))
        element("onboarding.tradition.continue", in: app).tap()
        XCTAssertTrue(element("onboarding.profileReveal.enter", in: app).waitForExistence(timeout: 3))
        element("onboarding.profileReveal.enter", in: app).tap()
    }
}
