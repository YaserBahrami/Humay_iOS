import XCTest

@MainActor
final class LaunchUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testOnboardingFlowCompletes() {
        let app = XCUIApplication()
        app.launch()

        XCTAssertTrue(
            app.buttons["onboarding.welcome.begin"].waitForExistence(timeout: 3)
        )
        app.buttons["onboarding.welcome.begin"].tap()

        XCTAssertTrue(
            app.buttons["onboarding.birthDate.continue"].waitForExistence(timeout: 3)
        )
        app.buttons["onboarding.birthDate.continue"].tap()

        XCTAssertTrue(
            app.buttons["onboarding.tradition.western"].waitForExistence(timeout: 3)
        )
        app.buttons["onboarding.tradition.continue"].tap()

        XCTAssertTrue(
            app.buttons["onboarding.profileReveal.enter"].waitForExistence(timeout: 3)
        )
        app.buttons["onboarding.profileReveal.enter"].tap()

        XCTAssertTrue(app.staticTexts["Humay"].waitForExistence(timeout: 3))
    }

    func testBirthDateBackReturnsToWelcome() {
        let app = XCUIApplication()
        app.launch()

        app.buttons["onboarding.welcome.begin"].tap()
        XCTAssertTrue(app.buttons["onboarding.step.back"].waitForExistence(timeout: 3))
        app.buttons["onboarding.step.back"].tap()

        XCTAssertTrue(
            app.buttons["onboarding.welcome.begin"].waitForExistence(timeout: 3)
        )
    }

    func testCaptureOnboardingEvidence() {
        let app = XCUIApplication()
        app.launch()

        capture(app, named: "01-welcome")

        app.buttons["onboarding.welcome.begin"].tap()
        XCTAssertTrue(
            app.buttons["onboarding.birthDate.continue"].waitForExistence(timeout: 3)
        )
        capture(app, named: "02-birth-date")

        app.buttons["onboarding.birthDate.continue"].tap()
        XCTAssertTrue(
            app.buttons["onboarding.tradition.continue"].waitForExistence(timeout: 3)
        )
        capture(app, named: "03-tradition")

        app.buttons["onboarding.tradition.continue"].tap()
        XCTAssertTrue(
            app.buttons["onboarding.profileReveal.enter"].waitForExistence(timeout: 3)
        )
        capture(app, named: "04-profile-reveal")
    }

    func testCaptureOnboardingLandscapeEvidence() {
        let app = XCUIApplication()
        app.launch()

        XCTAssertTrue(
            app.buttons["onboarding.welcome.begin"].waitForExistence(timeout: 3)
        )
        XCUIDevice.shared.orientation = .landscapeRight
        XCTAssertTrue(
            app.buttons["onboarding.welcome.begin"].waitForExistence(timeout: 3)
        )
        capture(app, named: "01-welcome-landscape")

        app.buttons["onboarding.welcome.begin"].tap()
        XCTAssertTrue(
            app.buttons["onboarding.birthDate.continue"].waitForExistence(timeout: 3)
        )
        capture(app, named: "02-birth-date-landscape")

        app.buttons["onboarding.birthDate.continue"].tap()
        XCTAssertTrue(
            app.buttons["onboarding.tradition.continue"].waitForExistence(timeout: 3)
        )
        capture(app, named: "03-tradition-landscape")

        app.buttons["onboarding.tradition.continue"].tap()
        XCTAssertTrue(
            app.buttons["onboarding.profileReveal.enter"].waitForExistence(timeout: 3)
        )
        capture(app, named: "04-profile-reveal-landscape")

        XCUIDevice.shared.orientation = .portrait
    }

    private func capture(_ app: XCUIApplication, named name: String) {
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
