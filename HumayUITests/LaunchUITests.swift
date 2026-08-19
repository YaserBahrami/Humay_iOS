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

    func testPremiumPrimaryNavigationAndExploreHub() {
        let app = d2App()

        for destination in ["Today", "Chart", "Explore", "Connections", "You"] {
            XCTAssertTrue(
                app.tabBars.buttons[destination].exists
                    || app.buttons[destination].firstMatch.exists,
                "Missing primary destination \(destination)"
            )
        }

        selectPrimaryDestination("Explore", in: app)
        XCTAssertTrue(element("explore.screen", in: app).waitForExistence(timeout: 3))
        XCTAssertTrue(app.buttons["explore.topic.love"].exists)
        XCTAssertTrue(app.buttons["explore.tool.current-sky"].exists)
        XCTAssertTrue(app.buttons["explore.tool.ask"].exists)

        selectPrimaryDestination("You", in: app)
        XCTAssertTrue(element("you.screen", in: app).waitForExistence(timeout: 3))
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
        selectPrimaryDestination("Connections", in: app)
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
            element("compatibility.basis.free", in: app).exists
        )
    }

    func testD2AddPersonValidation() {
        let app = d2App()

        selectPrimaryDestination("Connections", in: app)
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
        XCTAssertTrue(app.tabBars.buttons["Explore"].exists || app.buttons["Explore"].exists)
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

    func testD3CurrentSkyEventOpensLoadedDetailAndBack() {
        let app = d3App()
        let event = element("sky.current.event.development.sky.lunar", in: app)

        XCTAssertTrue(event.waitForExistence(timeout: 3))
        event.tap()
        XCTAssertTrue(element("sky.event-detail.screen", in: app).waitForExistence(timeout: 3))
        XCTAssertTrue(element("sky.event-detail.title", in: app).exists)
        XCTAssertTrue(app.staticTexts["Factual context"].exists)
        XCTAssertTrue(app.staticTexts["What this means"].exists)

        app.navigationBars.buttons.element(boundBy: 0).tap()
        XCTAssertTrue(event.waitForExistence(timeout: 3))
    }

    func testD3CalendarMonthEventOpensDetailAndPreservesSelection() {
        let app = d3App()
        app.buttons["sky.current.calendar-entry"].tap()

        let selectedDate = app.buttons["sky.calendar.month.date.2026-08-14"]
        XCTAssertTrue(selectedDate.waitForExistence(timeout: 3))
        selectedDate.tap()
        XCTAssertEqual(selectedDate.value as? String, "Selected")

        let event = element("sky.calendar.event.development.sky.ingress", in: app)
        XCTAssertTrue(event.waitForExistence(timeout: 3))
        event.tap()
        XCTAssertTrue(element("sky.event-detail.screen", in: app).waitForExistence(timeout: 3))
        XCTAssertTrue(element("sky.event-detail.title", in: app).exists)

        app.navigationBars.buttons.element(boundBy: 0).tap()
        XCTAssertTrue(element("sky.calendar.screen", in: app).waitForExistence(timeout: 3))
        XCTAssertEqual(selectedDate.value as? String, "Selected")
    }

    func testD3CalendarWeekEventOpensDetailAndPreservesModeAndDate() {
        let app = d3App()
        app.buttons["sky.current.calendar-entry"].tap()
        app.buttons["sky.calendar.mode.week"].tap()

        let selectedDate = app.buttons["sky.calendar.week.date.2026-08-14"]
        XCTAssertTrue(selectedDate.waitForExistence(timeout: 3))
        selectedDate.tap()
        XCTAssertEqual(selectedDate.value as? String, "Selected")

        let event = element("sky.calendar.event.development.sky.ingress", in: app)
        XCTAssertTrue(event.waitForExistence(timeout: 3))
        event.tap()
        XCTAssertTrue(element("sky.event-detail.screen", in: app).waitForExistence(timeout: 3))

        app.navigationBars.buttons.element(boundBy: 0).tap()
        XCTAssertTrue(element("sky.calendar.week.state.loaded", in: app).waitForExistence(timeout: 3))
        XCTAssertTrue(app.buttons["sky.calendar.mode.week"].isSelected)
        XCTAssertEqual(selectedDate.value as? String, "Selected")
    }

    func testD3EventDetailStatesRemainDistinct() {
        let states = [
            ("loading", "sky.event-detail.state.loading"),
            ("unavailable", "sky.event-detail.state.unavailable"),
            ("unsupported-methodology", "sky.event-detail.state.unavailable"),
            ("missing-time-zone", "sky.event-detail.state.unavailable"),
            ("missing-location", "sky.event-detail.state.unavailable"),
            ("event-not-found", "sky.event-detail.state.event-not-found"),
            ("offline", "sky.event-detail.state.offline.cached"),
            ("offline-empty", "sky.event-detail.state.offline.no-cache"),
            ("failed", "sky.event-detail.state.failed")
        ]

        for (argument, identifier) in states {
            let app = d3App(extraArguments: ["-HumayD3DetailState", argument])
            let event = element("sky.current.event.development.sky.lunar", in: app)
            XCTAssertTrue(event.waitForExistence(timeout: 3))
            event.tap()
            XCTAssertTrue(
                element("sky.event-detail.screen", in: app).waitForExistence(timeout: 3),
                "Missing Event Detail screen for \(argument)"
            )
            XCTAssertTrue(
                element(identifier, in: app).waitForExistence(timeout: 3),
                "Missing Event Detail state for \(argument)"
            )
            if argument == "offline" {
                XCTAssertTrue(element("sky.event-detail.offline.cached.notice", in: app).exists)
                XCTAssertTrue(element("sky.event-detail.title", in: app).exists)
            }
            app.terminate()
        }
    }

    func testCaptureD3EventDetailLightEvidence() {
        captureD3EventDetailEvidence(interfaceStyle: "Light")
    }

    func testCaptureD3EventDetailDarkEvidence() {
        captureD3EventDetailEvidence(interfaceStyle: "Dark")
    }

    private func captureD3EventDetailEvidence(interfaceStyle: String) {
        XCUIDevice.shared.orientation = .portrait
        let appearance = interfaceStyle.lowercased()
        let appearanceArguments = ["-AppleInterfaceStyle", interfaceStyle]

        let current = d3App(extraArguments: appearanceArguments)
        let lunar = element("sky.current.event.development.sky.lunar", in: current)
        XCTAssertTrue(lunar.waitForExistence(timeout: 3))
        lunar.tap()
        XCTAssertTrue(element("sky.event-detail.title", in: current).waitForExistence(timeout: 3))
        capture(current, named: "loaded-current-sky-\(appearance)")
        current.terminate()

        let calendar = d3App(extraArguments: appearanceArguments)
        calendar.buttons["sky.current.calendar-entry"].tap()
        calendar.buttons["sky.calendar.month.date.2026-08-14"].tap()
        let ingress = element("sky.calendar.event.development.sky.ingress", in: calendar)
        XCTAssertTrue(ingress.waitForExistence(timeout: 3))
        ingress.tap()
        XCTAssertTrue(element("sky.event-detail.title", in: calendar).waitForExistence(timeout: 3))
        capture(calendar, named: "loaded-calendar-\(appearance)")
        calendar.terminate()

        let longTitle = d3App(extraArguments: appearanceArguments)
        let ingressFromSky = element("sky.current.event.development.sky.ingress", in: longTitle)
        XCTAssertTrue(ingressFromSky.waitForExistence(timeout: 3))
        ingressFromSky.tap()
        XCTAssertTrue(element("sky.event-detail.title", in: longTitle).waitForExistence(timeout: 3))
        capture(longTitle, named: "long-title-\(appearance)")
        longTitle.terminate()

        let states = [
            ("loading", "sky.event-detail.state.loading"),
            ("unavailable", "sky.event-detail.state.unavailable"),
            ("offline", "sky.event-detail.state.offline.cached"),
            ("offline-empty", "sky.event-detail.state.offline.no-cache"),
            ("failed", "sky.event-detail.state.failed"),
            ("event-not-found", "sky.event-detail.state.event-not-found")
        ]

        for (argument, identifier) in states {
            let app = d3App(extraArguments: appearanceArguments + ["-HumayD3DetailState", argument])
            let event = element("sky.current.event.development.sky.lunar", in: app)
            XCTAssertTrue(event.waitForExistence(timeout: 3))
            event.tap()
            XCTAssertTrue(element(identifier, in: app).waitForExistence(timeout: 3))
            capture(app, named: "\(argument == "offline-empty" ? "offline-no-cache" : argument)-\(appearance)")
            app.terminate()
        }
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

    func testCaptureD3RefinementR1LightEvidence() {
        captureD3RefinementR1Evidence(appearance: "light")

        guard evidenceDevice == "iphone" else { return }
        let clearance = d3App()
        XCTAssertTrue(element("sky.current.coming-up", in: clearance).waitForExistence(timeout: 3))
        clearance.swipeUp()
        clearance.swipeUp()
        capture(clearance, named: "r1-iphone-bottom-tab-clearance")
    }

    func testCaptureD3RefinementR1DarkEvidence() {
        captureD3RefinementR1Evidence(appearance: "dark")
    }

    func testCaptureD3RefinementR1AccessibilityEvidence() {
        XCUIDevice.shared.orientation = .portrait
        let accessibility = d3App()
        XCTAssertTrue(element("sky.current.hero", in: accessibility).waitForExistence(timeout: 3))
        capture(accessibility, named: "r1-iphone-ax-current-sky")
    }

    private func captureD3RefinementR1Evidence(appearance: String) {
        XCUIDevice.shared.orientation = .portrait
        let app = d3App()

        XCTAssertTrue(element("sky.current.hero", in: app).waitForExistence(timeout: 3))
        capture(app, named: "r1-\(evidenceDevice)-\(appearance)-current-sky")

        app.buttons["sky.current.calendar-entry"].tap()
        XCTAssertTrue(element("sky.calendar.month.state.loaded", in: app).waitForExistence(timeout: 3))
        capture(app, named: "r1-\(evidenceDevice)-\(appearance)-month")

        app.buttons["sky.calendar.mode.week"].tap()
        XCTAssertTrue(element("sky.calendar.week.state.loaded", in: app).waitForExistence(timeout: 3))
        capture(app, named: "r1-\(evidenceDevice)-\(appearance)-week")
    }

    private var evidenceDevice: String {
        ProcessInfo.processInfo.environment["SIMULATOR_DEVICE_NAME"]?
            .localizedCaseInsensitiveContains("iPad") == true ? "ipad" : "iphone"
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
        selectPrimaryDestination("Connections", in: app)
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
            element("compatibility.basis.precise", in: app).exists
        )
        capture(app, named: "d2-compatibility")
    }

    func testCaptureCompatibilityRefreshEvidence() {
        let app = d2App()

        selectPrimaryDestination("Connections", in: app)
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
            element("compatibility.basis.free", in: app).exists
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

        selectPrimaryDestination("Connections", in: app)
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

    func testD4FreeEntryShowsReadinessAndNoNatalWheel() {
        let app = d4App()

        XCTAssertTrue(element("chart.state.free", in: app).exists)
        XCTAssertTrue(element("chart.free.preview.disclosure", in: app).exists)
        XCTAssertTrue(element("chart.readiness.time", in: app).exists)
        XCTAssertTrue(element("chart.readiness.place", in: app).exists)
        XCTAssertTrue(element("chart.precision-path", in: app).exists)
        XCTAssertFalse(app.staticTexts["Development sample · not calculated"].exists)
        XCTAssertFalse(app.staticTexts["Chart foundation is in place"].exists)
        XCTAssertFalse(element("chart.wheel", in: app).exists)
    }

    func testD4LoadedWesternChartOpensPlacementDetail() {
        let app = d4App(extraArguments: [
            "-HumayD4ChartState", "loaded"
        ])

        XCTAssertTrue(element("chart.state.loaded", in: app).waitForExistence(timeout: 3))
        XCTAssertTrue(
            app.staticTexts["Development sample · not calculated"].waitForExistence(timeout: 3)
        )
        app.buttons["chart.western.open"].tap()
        XCTAssertTrue(element("chart.western.screen", in: app).waitForExistence(timeout: 3))
        let wheel = element("chart.wheel", in: app)
        for _ in 0..<3 where !wheel.exists {
            app.swipeUp()
        }
        XCTAssertTrue(wheel.waitForExistence(timeout: 3))

        let moonDetail = app.buttons["chart.placement.moon.open"]
        for _ in 0..<3 where !moonDetail.isHittable {
            app.swipeUp()
        }
        XCTAssertTrue(moonDetail.isHittable)
        moonDetail.tap()

        XCTAssertTrue(element("chart.placement-detail.screen", in: app).waitForExistence(timeout: 3))
        XCTAssertTrue(element("chart.placement-detail.facts", in: app).exists)
        XCTAssertTrue(element("chart.placement-detail.interpretation", in: app).exists)
        XCTAssertTrue(app.staticTexts["14° 27′"].exists)

        app.navigationBars.buttons.element(boundBy: 0).tap()
        XCTAssertTrue(element("chart.western.screen", in: app).waitForExistence(timeout: 3))
        let bigThree = element("chart.big-three", in: app)
        for _ in 0..<3 where !bigThree.exists {
            app.swipeUp()
        }
        XCTAssertTrue(bigThree.waitForExistence(timeout: 3))
    }

    func testD4UnknownTimeWithholdsPrecisionFacts() {
        let app = d4App(extraArguments: [
            "-HumayD4ChartState", "unknown-time"
        ])

        XCTAssertTrue(element("chart.unknown-time.screen", in: app).waitForExistence(timeout: 3))
        XCTAssertFalse(app.staticTexts["Development sample · not calculated"].exists)
        XCTAssertTrue(
            element("chart.unknown-time.warning", in: app).exists
                || app.staticTexts["Birth time unknown"].exists
        )
        app.swipeUp()
        XCTAssertTrue(
            element("chart.unknown-time.known-facts", in: app).exists
                || app.staticTexts["Known from the date"].exists
        )
        XCTAssertTrue(app.staticTexts["Sun in Pisces"].exists)
        XCTAssertFalse(app.staticTexts["22° 11′"].exists)
        app.swipeUp()
        XCTAssertTrue(
            element("chart.unknown-time.withheld", in: app).exists
                || app.staticTexts["Not available without more precision"].exists
        )
        app.swipeUp()
        XCTAssertTrue(
            element("chart.readiness.time", in: app).exists
                || app.staticTexts["Birth time"].exists
        )
        XCTAssertFalse(element("chart.wheel", in: app).exists)
        XCTAssertFalse(app.staticTexts["03° 02′"].exists)
    }

    func testD4FreeEntryDynamicTypeRemainsNavigable() {
        let app = d4App(extraArguments: [
            "-UIPreferredContentSizeCategory", "UICTContentSizeCategoryAccessibilityXXXL"
        ])

        XCTAssertTrue(element("chart.state.free", in: app).waitForExistence(timeout: 3))
        XCTAssertTrue(element("chart.readiness", in: app).exists)
        XCTAssertTrue(element("chart.precision-path", in: app).exists)
        XCTAssertFalse(element("chart.wheel", in: app).exists)
    }

    func testCaptureD4HardeningEvidence() {
        for interfaceStyle in ["Light", "Dark"] {
            let appearance = interfaceStyle.lowercased()
            let appearanceArguments = ["-AppleInterfaceStyle", interfaceStyle]

            let free = d4App(extraArguments: appearanceArguments)
            XCTAssertTrue(element("chart.state.free", in: free).waitForExistence(timeout: 3))
            capture(free, named: "free-entry-\(evidenceDevice)-\(appearance)")
            free.terminate()

            let unknownTime = d4App(extraArguments: appearanceArguments + [
                "-HumayD4ChartState", "unknown-time"
            ])
            XCTAssertTrue(element("chart.unknown-time.screen", in: unknownTime).waitForExistence(timeout: 3))
            capture(unknownTime, named: "unknown-time-\(evidenceDevice)-\(appearance)")
            unknownTime.terminate()

            let loaded = d4App(extraArguments: appearanceArguments + [
                "-HumayD4ChartState", "loaded"
            ])
            loaded.buttons["chart.western.open"].tap()
            XCTAssertTrue(element("chart.western.screen", in: loaded).waitForExistence(timeout: 3))
            capture(loaded, named: "western-loaded-\(evidenceDevice)-\(appearance)")
            loaded.terminate()

            if interfaceStyle == "Light", evidenceDevice == "iphone" {
                let dynamicType = d4App(extraArguments: appearanceArguments + [
                    "-UIPreferredContentSizeCategory", "UICTContentSizeCategoryAccessibilityXXXL"
                ])
                XCTAssertTrue(element("chart.state.free", in: dynamicType).waitForExistence(timeout: 3))
                capture(dynamicType, named: "dynamic-type-large-iphone-light")
                dynamicType.terminate()
            }
        }
    }

    func testD4TypedStatesRemainDistinct() {
        let states: [(String, String)] = [
            ("loading", "loading"),
            ("locked", "precision-locked"),
            ("available", "generation-available"),
            ("loaded", "loaded"),
            ("cached", "cached"),
            ("offline", "offline.cached"),
            ("offline-empty", "offline.no-cache"),
            ("unsupported", "unsupported"),
            ("unknown-time", "insufficient-precision"),
            ("failed", "failed")
        ]

        for (state, identifier) in states {
            let app = d4App(extraArguments: [
                "-HumayD4ChartState", state
            ])
            let elementIdentifier = state == "unknown-time"
                ? "chart.unknown-time.screen"
                : "chart.state.\(identifier)"
            XCTAssertTrue(
                element(elementIdentifier, in: app).waitForExistence(timeout: 3),
                "Missing D4 state \(state)"
            )
            app.terminate()
        }
    }

    func testCapturePremiumAssetCorrectionPortraitLightEvidence() {
        XCUIDevice.shared.orientation = .portrait
        capturePremiumAssetCorrection(
            interfaceStyle: "Light",
            orientationLabel: "portrait"
        )
    }

    func testCapturePremiumAssetCorrectionPortraitDarkEvidence() {
        XCUIDevice.shared.orientation = .portrait
        capturePremiumAssetCorrection(
            interfaceStyle: "Dark",
            orientationLabel: "portrait"
        )
    }

    func testCapturePremiumAssetCorrectionLandscapeEvidence() {
        XCUIDevice.shared.orientation = .landscapeRight
        capturePremiumAssetCorrection(
            interfaceStyle: "Light",
            orientationLabel: "landscape"
        )
        XCUIDevice.shared.orientation = .portrait
    }

    private func capturePremiumAssetCorrection(
        interfaceStyle: String,
        orientationLabel: String
    ) {
        let appearance = interfaceStyle.lowercased()
        let suffix = ["asset", evidenceDevice, orientationLabel, appearance]
            .joined(separator: "-")
        let arguments = [
            "-AppleInterfaceStyle", interfaceStyle,
            "-HumayD4ChartState", "loaded",
            "-HumayD2CompatibilityState", "precise"
        ]

        let primary = d2App(extraArguments: arguments)
        capture(primary, named: "today-" + suffix)

        selectPrimaryDestination("Explore", in: primary)
        XCTAssertTrue(element("explore.screen", in: primary).waitForExistence(timeout: 3))
        capture(primary, named: "explore-" + suffix)

        selectPrimaryDestination("Chart", in: primary)
        XCTAssertTrue(element("chart.state.loaded", in: primary).waitForExistence(timeout: 3))
        primary.buttons["chart.western.open"].tap()
        XCTAssertTrue(element("chart.western.screen", in: primary).waitForExistence(timeout: 3))
        capture(primary, named: "western-chart-" + suffix)

        let placement = primary.buttons["chart.placement.moon.open"]
        for _ in 0..<4 where !placement.isHittable {
            primary.swipeUp()
        }
        XCTAssertTrue(placement.isHittable)
        placement.tap()
        XCTAssertTrue(element("chart.placement-detail.screen", in: primary).waitForExistence(timeout: 3))
        capture(primary, named: "placement-detail-" + suffix)
        primary.terminate()

        let compatibility = d2App(extraArguments: arguments)
        selectPrimaryDestination("Connections", in: compatibility)
        compatibility.buttons["circle.compatibility.open"].tap()
        XCTAssertTrue(
            compatibility.buttons["compatibility.selection.continue"]
                .waitForExistence(timeout: 3)
        )
        capture(compatibility, named: "compatibility-selection-" + suffix)
        compatibility.buttons["compatibility.selection.continue"].tap()
        XCTAssertTrue(compatibility.staticTexts["compatibility.score"].waitForExistence(timeout: 3))
        capture(compatibility, named: "compatibility-result-" + suffix)
        compatibility.terminate()
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
        selectPrimaryDestination("Explore", in: app)
        let currentSky = app.buttons["explore.tool.current-sky"]
        XCTAssertTrue(currentSky.waitForExistence(timeout: 3))
        currentSky.tap()
        return app
    }

    private func d4App(extraArguments: [String] = []) -> XCUIApplication {
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
        selectPrimaryDestination("Chart", in: app)
        XCTAssertTrue(element("chart.screen", in: app).waitForExistence(timeout: 5))
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
