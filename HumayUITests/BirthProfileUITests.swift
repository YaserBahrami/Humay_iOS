import XCTest

@MainActor
final class BirthProfileUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    // MARK: - Onboarding with exact time + place (mock search)

    func testOnboardingExactTimeAndPlacePreview() {
        let app = freshAppWithMockSearch()

        element("onboarding.welcome.begin", in: app).tap()
        XCTAssertTrue(element("onboarding.birthDate.continue", in: app).waitForExistence(timeout: 3))
        element("onboarding.birthDate.continue", in: app).tap()

        // Birth time — select Exact
        XCTAssertTrue(element("onboarding.birthTime.kind.exact", in: app).waitForExistence(timeout: 3))
        element("onboarding.birthTime.kind.exact", in: app).tap()
        XCTAssertTrue(element("onboarding.birthTime.screen", in: app).waitForExistence(timeout: 1))
        tapContinue(in: app, identifier: "onboarding.birthTime.continue", fallbackLabels: ["Continue", "Continue without time"])

        // Birth place — mock search for Tehran
        XCTAssertTrue(app.textFields["onboarding.birthPlace.field"].waitForExistence(timeout: 3))
        let field = app.textFields["onboarding.birthPlace.field"]
        field.tap()
        field.typeText("Tehran")
        // Wait for mock result
        let result = element("onboarding.birthPlace.result.tehran-ir", in: app)
        XCTAssertTrue(result.waitForExistence(timeout: 5), "Mock search should return Tehran")
        result.tap()
        XCTAssertTrue(element("onboarding.birthPlace.selected", in: app).waitForExistence(timeout: 2))
        tapContinue(in: app, identifier: "onboarding.birthPlace.continue", fallbackLabels: ["Continue", "Use this place"])

        // Name
        XCTAssertTrue(element("onboarding.name.continue", in: app).waitForExistence(timeout: 3))
        element("onboarding.name.continue", in: app).tap()

        // Tradition
        XCTAssertTrue(element("onboarding.tradition.continue", in: app).waitForExistence(timeout: 3))
        element("onboarding.tradition.continue", in: app).tap()

        // Reveal should show BigThree preview (mock Tehran + exact time -> Rising available)
        XCTAssertTrue(element("onboarding.profileReveal.bigThree", in: app).waitForExistence(timeout: 3))
        XCTAssertTrue(element("onboarding.profileReveal.enter", in: app).waitForExistence(timeout: 2))
        element("onboarding.profileReveal.enter", in: app).tap()
        XCTAssertTrue(app.staticTexts["main.today.wordmark"].waitForExistence(timeout: 3))
    }

    func testOnboardingUnknownTimeSkipsPlaceAndShowsHonestPreview() {
        let app = freshAppWithMockSearch()

        element("onboarding.welcome.begin", in: app).tap()
        element("onboarding.birthDate.continue", in: app).tap()

        // Unknown time is default — just continue
        XCTAssertTrue(element("onboarding.birthTime.continue", in: app).waitForExistence(timeout: 5) || app.buttons["Continue without time"].waitForExistence(timeout: 3))
        tapContinue(in: app, identifier: "onboarding.birthTime.continue", fallbackLabels: ["Continue without time", "Continue"])

        // Skip place
        XCTAssertTrue(element("onboarding.birthPlace.continue", in: app).waitForExistence(timeout: 3))
        if element("onboarding.birthPlace.skip", in: app).waitForExistence(timeout: 1) {
            element("onboarding.birthPlace.skip", in: app).tap()
        } else {
            tapContinue(in: app, identifier: "onboarding.birthPlace.continue", fallbackLabels: ["Continue"])
        }

        XCTAssertTrue(element("onboarding.name.continue", in: app).waitForExistence(timeout: 3))
        element("onboarding.name.continue", in: app).tap()
        XCTAssertTrue(element("onboarding.tradition.continue", in: app).waitForExistence(timeout: 3))
        element("onboarding.tradition.continue", in: app).tap()

        XCTAssertTrue(element("onboarding.profileReveal.bigThree", in: app).waitForExistence(timeout: 3) ||
                      element("onboarding.profileReveal.summary", in: app).waitForExistence(timeout: 3))
        element("onboarding.profileReveal.enter", in: app).tap()
        XCTAssertTrue(app.staticTexts["main.today.wordmark"].waitForExistence(timeout: 3))
    }

    // MARK: - Settings Birth Details editing

    func testSettingsBirthDetailsEditAndCancel() {
        let app = demoAppWithMockSearch()
        selectYou(in: app)
        // Open profile settings via header button
        let profileButton = element("main.profile.button", in: app)
        XCTAssertTrue(profileButton.waitForExistence(timeout: 3), "Profile button not found")
        profileButton.tap()
        // Profile sheet should appear
        XCTAssertTrue(element("profile.birthDetails.edit", in: app).waitForExistence(timeout: 3))
        element("profile.birthDetails.edit", in: app).tap()

        // Birth details editor
        XCTAssertTrue(app.navigationBars["Birth Details"].waitForExistence(timeout: 3))
        // Cancel should preserve old value — tap Cancel
        app.buttons["Cancel"].tap()
        XCTAssertTrue(element("profile.birthDetails.edit", in: app).waitForExistence(timeout: 2))
        element("profile.birthDetails.edit", in: app).tap()
        XCTAssertTrue(app.navigationBars["Birth Details"].waitForExistence(timeout: 3))
        // Tap Save (should succeed even without changes)
        if app.buttons["Save"].waitForExistence(timeout: 2) { app.buttons["Save"].tap() }
        XCTAssertTrue(element("profile.birthDetails.edit", in: app).waitForExistence(timeout: 2))
        app.buttons["Done"].tap()
        XCTAssertTrue(app.tabBars.buttons["You"].waitForExistence(timeout: 3) || app.staticTexts["main.today.wordmark"].waitForExistence(timeout: 3))
    }

    // MARK: - Helpers

    private func freshAppWithMockSearch() -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments.append("-HumayResetPersistence")
        app.launchArguments.append("-HumayMockSearch")
        app.launch()
        XCTAssertTrue(element("onboarding.welcome.begin", in: app).waitForExistence(timeout: 5))
        return app
    }

    private func demoAppWithMockSearch() -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments += ["-HumayResetPersistence", "-HumayDemo", "-HumayMockSearch"]
        app.launch()
        XCTAssertTrue(app.staticTexts["main.today.wordmark"].waitForExistence(timeout: 5))
        return app
    }

    private func element(_ identifier: String, in app: XCUIApplication) -> XCUIElement {
        app.descendants(matching: .any)[identifier]
    }

    private func tapContinue(in app: XCUIApplication, identifier: String, fallbackLabels: [String]) {
        if element(identifier, in: app).waitForExistence(timeout: 3) {
            element(identifier, in: app).tap(); return
        }
        for label in fallbackLabels {
            let btn = app.buttons[label].firstMatch
            if btn.waitForExistence(timeout: 1) { btn.tap(); return }
            let any = app.descendants(matching: .any)[label].firstMatch
            if any.waitForExistence(timeout: 1) { any.tap(); return }
        }
        XCTFail("Continue not found \(identifier)")
    }

    private func selectYou(in app: XCUIApplication) {
        let tab = app.tabBars.buttons["You"]
        if tab.waitForExistence(timeout: 2) { tab.tap(); return }
        let cell = app.cells["You"].firstMatch
        if cell.waitForExistence(timeout: 1) { cell.tap(); return }
        let btn = app.buttons["You"].firstMatch
        XCTAssertTrue(btn.waitForExistence(timeout: 3)); btn.tap()
    }
}
