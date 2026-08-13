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

    func testD3CurrentSkyLoadedRendersApprovedHierarchy() {
        let app = d3App()

        XCTAssertTrue(app.staticTexts["Sky"].waitForExistence(timeout: 3))
        XCTAssertTrue(
            app.staticTexts["Development sample · not calculated"].waitForExistence(timeout: 3)
        )
        XCTAssertTrue(element("sky.current.hero", in: app).waitForExistence(timeout: 3))
        XCTAssertTrue(element("sky.current.happening-now", in: app).waitForExistence(timeout: 3))
        XCTAssertTrue(app.buttons["sky.current.calendar-entry"].waitForExistence(timeout: 3))
        XCTAssertTrue(element("sky.current.coming-up", in: app).waitForExistence(timeout: 3))
        XCTAssertTrue(app.tabBars.buttons["Sky"].exists || app.buttons["Sky"].exists)
    }

    func testD3CurrentSkyStatesRemainDistinct() {
        for state in ["loading", "empty", "unavailable", "offline-empty", "failed"] {
            let app = d3App(extraArguments: ["-HumayD3SkyState", state])

            XCTAssertTrue(
                element("sky.current.state.\(stateIdentifier(for: state))", in: app)
                    .waitForExistence(timeout: 3),
                "Missing Current Sky state for \(state)"
            )
            app.terminate()
        }
    }

    func testD3CurrentSkyOfflineCachedKeepsEvents() {
        let app = d3App(extraArguments: ["-HumayD3SkyState", "offline"])

        XCTAssertTrue(element("sky.current.offline.cached.notice", in: app).exists)
        XCTAssertTrue(element("sky.current.happening-now", in: app).exists)
    }

    func testD3CalendarNavigatesFromSkyAndPreservesSelection() {
        let app = d3App()

        app.buttons["sky.current.calendar-entry"].tap()
        XCTAssertTrue(element("sky.calendar.screen", in: app).waitForExistence(timeout: 3))
        XCTAssertTrue(element("sky.calendar.month.state.loaded", in: app).exists)
        XCTAssertTrue(app.staticTexts["August 2026"].exists)

        let eventDate = app.buttons["sky.calendar.month.date.2026-08-14"]
        XCTAssertTrue(eventDate.waitForExistence(timeout: 3))
        eventDate.tap()
        XCTAssertEqual(eventDate.value as? String, "Selected")
        XCTAssertTrue(app.staticTexts["3 events"].waitForExistence(timeout: 3))

        let quietDate = app.buttons["sky.calendar.month.date.2026-08-11"]
        XCTAssertTrue(quietDate.waitForExistence(timeout: 3))
        quietDate.tap()
        XCTAssertEqual(quietDate.value as? String, "Selected")
        app.swipeUp()
        XCTAssertTrue(app.staticTexts["Quiet sky this day"].waitForExistence(timeout: 3))

        app.buttons["sky.calendar.mode.week"].tap()
        XCTAssertTrue(element("sky.calendar.week.state.loaded", in: app).waitForExistence(timeout: 3))
        let weekQuietDate = app.buttons["sky.calendar.week.date.2026-08-11"]
        XCTAssertTrue(weekQuietDate.waitForExistence(timeout: 3))
        XCTAssertEqual(weekQuietDate.value as? String, "Selected")

        app.buttons["sky.calendar.mode.month"].tap()
        XCTAssertTrue(element("sky.calendar.month.state.loaded", in: app).waitForExistence(timeout: 3))
        XCTAssertEqual(
            app.buttons["sky.calendar.month.date.2026-08-11"].value as? String,
            "Selected"
        )

        app.buttons["sky.calendar.today"].tap()
        XCTAssertEqual(
            app.buttons["sky.calendar.month.date.2026-08-13"].value as? String,
            "Selected"
        )

        app.navigationBars.buttons.element(boundBy: 0).tap()
        XCTAssertTrue(app.buttons["sky.current.calendar-entry"].waitForExistence(timeout: 3))
    }

    func testD3CalendarMonthStatesRemainDistinct() {
        let states = [
            ("loading", "loading"),
            ("empty", "empty"),
            ("unavailable", "unavailable"),
            ("offline", "offline.cached"),
            ("offline-empty", "offline.no-cache"),
            ("failed", "failed")
        ]

        for (argument, identifier) in states {
            let app = d3App(extraArguments: ["-HumayD3MonthState", argument])
            app.buttons["sky.current.calendar-entry"].tap()
            XCTAssertTrue(
                element("sky.calendar.month.state.\(identifier)", in: app)
                    .waitForExistence(timeout: 3),
                "Missing Month state \(argument)"
            )
            if argument == "offline" {
                XCTAssertTrue(element("sky.calendar.month.state.offline.cached", in: app).exists)
                XCTAssertTrue(element("sky.calendar.offline.cached.notice", in: app).exists)
            }
            app.terminate()
        }
    }

    func testD3CalendarWeekStatesRemainDistinct() {
        let states = [
            ("loading", "loading"),
            ("empty", "empty"),
            ("unavailable", "unavailable"),
            ("offline", "offline.cached"),
            ("offline-empty", "offline.no-cache"),
            ("failed", "failed")
        ]

        for (argument, identifier) in states {
            let app = d3App(extraArguments: ["-HumayD3WeekState", argument])
            app.buttons["sky.current.calendar-entry"].tap()
            app.buttons["sky.calendar.mode.week"].tap()
            XCTAssertTrue(
                element("sky.calendar.week.state.\(identifier)", in: app)
                    .waitForExistence(timeout: 3),
                "Missing Week state \(argument)"
            )
            if argument == "offline" {
                XCTAssertTrue(element("sky.calendar.week.state.offline.cached", in: app).exists)
                XCTAssertTrue(element("sky.calendar.offline.cached.notice", in: app).exists)
            }
            app.terminate()
        }
    }

    func testCaptureD3CalendarLoadedAndStates() {
        captureD3CalendarEvidence(interfaceStyle: "Light")
    }

    func testCaptureD3CalendarDarkEvidence() {
        captureD3CalendarEvidence(interfaceStyle: "Dark")
    }

    private func captureD3CalendarEvidence(interfaceStyle: String) {
        XCUIDevice.shared.orientation = .portrait
        let appearance = interfaceStyle.lowercased()
        let appearanceArguments = ["-AppleInterfaceStyle", interfaceStyle]

        let loaded = d3App(extraArguments: appearanceArguments)
        loaded.buttons["sky.current.calendar-entry"].tap()
        XCTAssertTrue(element("sky.calendar.screen", in: loaded).waitForExistence(timeout: 3))
        XCTAssertTrue(element("sky.calendar.month.state.loaded", in: loaded).exists)
        capture(loaded, named: "calendar-month-loaded-\(appearance)")

        let quietDate = loaded.buttons["sky.calendar.month.date.2026-08-11"]
        XCTAssertTrue(quietDate.waitForExistence(timeout: 3))
        quietDate.tap()
        loaded.swipeUp()
        XCTAssertTrue(loaded.staticTexts["Quiet sky this day"].waitForExistence(timeout: 3))
        capture(loaded, named: "calendar-month-quiet-\(appearance)")
        loaded.swipeDown()
        loaded.swipeDown()
        loaded.buttons["sky.calendar.month.date.2026-08-14"].tap()

        loaded.buttons["sky.calendar.mode.week"].tap()
        XCTAssertTrue(element("sky.calendar.week.state.loaded", in: loaded).waitForExistence(timeout: 3))
        loaded.swipeDown()
        loaded.swipeDown()
        capture(loaded, named: "calendar-week-loaded-\(appearance)")
        loaded.terminate()

        for state in ["loading", "empty", "unavailable", "offline", "offline-empty", "failed"] {
            let app = d3App(extraArguments: appearanceArguments + ["-HumayD3MonthState", state])
            app.buttons["sky.current.calendar-entry"].tap()
            let identifier = state == "offline"
                ? "sky.calendar.month.state.offline.cached"
                : state == "offline-empty"
                        ? "sky.calendar.month.state.offline.no-cache"
                        : "sky.calendar.month.state.\(state)"
            XCTAssertTrue(element(identifier, in: app).waitForExistence(timeout: 3))
            capture(app, named: "calendar-month-\(state)-\(appearance)")
            app.terminate()
        }
    }

    func testCaptureD3CurrentSkyEvidence() {
        XCUIDevice.shared.orientation = .portrait

        let loaded = d3App()
        XCTAssertTrue(element("sky.current.hero", in: loaded).waitForExistence(timeout: 3))
        capture(loaded, named: "current-sky-loaded")
        loaded.terminate()

        for state in ["loading", "empty", "unavailable", "offline", "offline-empty", "failed"] {
            let app = d3App(extraArguments: ["-HumayD3SkyState", state])
            let stateElement = state == "offline"
                ? "sky.current.offline.cached.notice"
                : "sky.current.state.\(stateIdentifier(for: state))"
            XCTAssertTrue(
                element(stateElement, in: app)
                    .waitForExistence(timeout: 3)
            )
            capture(app, named: "current-sky-\(state)")
            app.terminate()
        }
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

    private func d3App(extraArguments: [String] = []) -> XCUIApplication {
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
        selectPrimaryDestination("Sky", in: app)
        return app
    }

    private func stateIdentifier(for state: String) -> String {
        switch state {
        case "offline-empty": "offline.no-cache"
        default: state
        }
    }

    private func element(_ identifier: String, in app: XCUIApplication) -> XCUIElement {
        app.descendants(matching: .any)[identifier]
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
