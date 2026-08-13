import XCTest

@MainActor
final class LaunchUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

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
            app.buttons["onboarding.tradition.western"].waitForExistence(timeout: 3)
        )
        app.buttons["onboarding.tradition.continue"].tap()

        XCTAssertTrue(
            app.buttons["onboarding.profileReveal.enter"].waitForExistence(timeout: 3)
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

    func testD2PrimaryNavigationAndCompatibilityFlow() {
        let app = d2App()

        XCTAssertTrue(
            app.buttons["today.daily.open"].waitForExistence(timeout: 3)
        )
        app.buttons["today.daily.open"].tap()
        XCTAssertTrue(
            app.otherElements["daily.reading.card"].waitForExistence(timeout: 3)
                || app.staticTexts["daily.reading.card"].waitForExistence(timeout: 1)
        )

        app.navigationBars["Daily Horoscope"].buttons.element(boundBy: 0).tap()
        selectPrimaryDestination("Circle", in: app)
        XCTAssertTrue(
            app.buttons["circle.compatibility.open"].waitForExistence(timeout: 3)
        )
        app.buttons["circle.compatibility.open"].tap()
        XCTAssertTrue(
            app.buttons["compatibility.selection.continue"].waitForExistence(timeout: 3)
        )
        XCTAssertTrue(
            app.otherElements["compatibility.pair-composer"].exists
                || app.staticTexts["compatibility.pair-composer"].exists
        )
        let firstPerson = app.buttons["compatibility.selection.person.0"]
        XCTAssertTrue(firstPerson.waitForExistence(timeout: 3))
        XCTAssertEqual(firstPerson.value as? String, "Selected")

        firstPerson.tap()
        XCTAssertEqual(firstPerson.value as? String, "Not selected")
        XCTAssertFalse(app.buttons["compatibility.selection.continue"].isEnabled)

        firstPerson.tap()
        XCTAssertEqual(firstPerson.value as? String, "Selected")
        XCTAssertTrue(app.buttons["compatibility.selection.continue"].isEnabled)

        app.buttons["compatibility.selection.continue"].tap()
        XCTAssertTrue(
            app.staticTexts["compatibility.score"].waitForExistence(timeout: 3)
        )
        XCTAssertTrue(
            app.otherElements["compatibility.basis.free"].exists
                || app.staticTexts["compatibility.basis.free"].exists
        )
    }

    func testD2AddPersonValidation() {
        let app = d2App()

        selectPrimaryDestination("Circle", in: app)
        XCTAssertTrue(
            app.buttons["circle.add-person"].waitForExistence(timeout: 3)
        )
        app.buttons["circle.add-person"].tap()
        XCTAssertTrue(
            app.buttons["circle.add-person.save"].waitForExistence(timeout: 3)
        )
        app.buttons["circle.add-person.save"].tap()
        XCTAssertTrue(
            app.staticTexts["circle.add-person.error"].waitForExistence(timeout: 3)
                || app.otherElements["circle.add-person.error"].waitForExistence(timeout: 1)
        )
    }

    func testCaptureD2Evidence() {
        let app = d2App(extraArguments: [
            "-HumayD2CompatibilityState", "precise"
        ])

        capture(app, named: "d2-today")

        app.buttons["today.daily.open"].tap()
        XCTAssertTrue(
            app.navigationBars["Daily Horoscope"].waitForExistence(timeout: 3)
        )
        capture(app, named: "d2-daily-horoscope")

        app.navigationBars["Daily Horoscope"].buttons.element(boundBy: 0).tap()
        selectPrimaryDestination("Circle", in: app)
        XCTAssertTrue(
            app.buttons["circle.compatibility.open"].waitForExistence(timeout: 3)
        )
        capture(app, named: "d2-circle")

        app.buttons["circle.compatibility.open"].tap()
        XCTAssertTrue(
            app.buttons["compatibility.selection.continue"].waitForExistence(timeout: 3)
        )
        app.buttons["compatibility.selection.continue"].tap()
        XCTAssertTrue(
            app.staticTexts["compatibility.score"].waitForExistence(timeout: 3)
        )
        XCTAssertTrue(
            app.otherElements["compatibility.basis.precise"].exists
                || app.staticTexts["compatibility.basis.precise"].exists
        )
        capture(app, named: "d2-compatibility")
    }

    func testCaptureCompatibilityRefreshEvidence() {
        let app = d2App()

        selectPrimaryDestination("Circle", in: app)
        XCTAssertTrue(
            app.buttons["circle.compatibility.open"].waitForExistence(timeout: 3)
        )
        app.buttons["circle.compatibility.open"].tap()
        XCTAssertTrue(
            app.buttons["compatibility.selection.continue"].waitForExistence(timeout: 3)
        )
        capture(app, named: "compatibility-refresh-selection")

        app.buttons["compatibility.selection.continue"].tap()
        XCTAssertTrue(
            app.staticTexts["compatibility.score"].waitForExistence(timeout: 3)
        )
        XCTAssertTrue(
            app.otherElements["compatibility.basis.free"].exists
                || app.staticTexts["compatibility.basis.free"].exists
        )
        capture(app, named: "compatibility-refresh-result")
    }

    func testCaptureD2LandscapeEvidence() {
        let app = d2App(extraArguments: [
            "-HumayD2CompatibilityState", "precise"
        ])

        XCUIDevice.shared.orientation = .landscapeRight
        XCTAssertTrue(
            app.staticTexts["main.today.wordmark"].waitForExistence(timeout: 3)
        )
        capture(app, named: "d2-today-landscape")

        selectPrimaryDestination("Circle", in: app)
        app.buttons["circle.compatibility.open"].tap()
        XCTAssertTrue(
            app.buttons["compatibility.selection.continue"].waitForExistence(timeout: 3)
        )
        app.buttons["compatibility.selection.continue"].tap()
        XCTAssertTrue(
            app.staticTexts["compatibility.score"].waitForExistence(timeout: 3)
        )
        capture(app, named: "d2-compatibility-landscape")

        XCUIDevice.shared.orientation = .portrait
    }

    func testBirthDateBackReturnsToWelcome() {
        let app = freshApp()

        app.buttons["onboarding.welcome.begin"].tap()
        XCTAssertTrue(app.buttons["onboarding.step.back"].waitForExistence(timeout: 3))
        app.buttons["onboarding.step.back"].tap()

        XCTAssertTrue(
            app.buttons["onboarding.welcome.begin"].waitForExistence(timeout: 3)
        )
    }

    func testCaptureOnboardingEvidence() {
        let app = freshApp()

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
        let app = freshApp()

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

    private func freshApp() -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments.append("-HumayResetPersistence")
        app.launch()
        XCTAssertTrue(
            app.buttons["onboarding.welcome.begin"].waitForExistence(timeout: 5)
        )
        return app
    }

    private func d2App(extraArguments: [String] = []) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments += [
            "-HumayResetPersistence",
            "-HumayD2Demo"
        ]
        app.launchArguments += extraArguments
        app.launch()
        XCTAssertTrue(
            app.staticTexts["main.today.wordmark"].waitForExistence(timeout: 5)
        )
        return app
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
            app.buttons["onboarding.tradition.continue"].waitForExistence(timeout: 3)
        )
        app.buttons["onboarding.tradition.continue"].tap()
        XCTAssertTrue(
            app.buttons["onboarding.profileReveal.enter"].waitForExistence(timeout: 3)
        )
        app.buttons["onboarding.profileReveal.enter"].tap()
    }

    private func capture(_ app: XCUIApplication, named name: String) {
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
