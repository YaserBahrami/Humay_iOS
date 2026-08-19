import XCTest

@MainActor
final class D5AskUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testAskEntryKeepsComposerEarlyAndContextVisible() {
        let app = askApp()

        XCTAssertTrue(element("ask.entry.screen", in: app).waitForExistence(timeout: 3))
        XCTAssertTrue(app.staticTexts["What’s on your mind?"].exists)
        XCTAssertTrue(element("ask.composer", in: app).exists)
        XCTAssertTrue(element("ask.composer.action", in: app).exists)
        XCTAssertTrue(element("ask.suggestions", in: app).exists)
        XCTAssertTrue(element("ask.context", in: app).exists)
        XCTAssertTrue(app.staticTexts["AVAILABLE CONTEXT"].exists)
        XCTAssertFalse(app.staticTexts["Development sample · not generated"].exists)
    }

    func testPrimarySuggestionFillsComposerAndStopsAtAccess() {
        let app = askApp()

        let suggestion = element("ask.suggestion.1", in: app)
        XCTAssertTrue(suggestion.waitForExistence(timeout: 3))
        suggestion.tap()

        let composer = element("ask.composer", in: app)
        XCTAssertTrue(composer.value as? String == "How can I work with my Moon in Libra?")
        app.buttons["ask.composer.action"].tap()

        XCTAssertTrue(element("ask.access.screen", in: app).waitForExistence(timeout: 3))
        XCTAssertTrue(app.staticTexts["YOUR QUESTION IS READY"].exists)
        XCTAssertTrue(app.staticTexts["Create this personal reading by watching an ad."].exists)
        XCTAssertTrue(app.buttons["ask.access.watch"].exists)
        XCTAssertFalse(app.staticTexts["A gentler kind of balance"].exists)
    }

    func testAskStateFixturesRemainDistinct() {
        let states: [(String, String)] = [
            ("access", "ask.access.screen"),
            ("generating", "ask.generating.screen"),
            ("loaded", "ask.answer.screen"),
            ("cached", "ask.answer.screen"),
            ("offline-cached", "ask.answer.screen"),
            ("offline-empty", "ask.state.offline.no-cache"),
            ("insufficient", "ask.state.insufficient-context"),
            ("unsupported", "ask.state.unsupported"),
            ("safety", "ask.state.safety-refusal"),
            ("failed", "ask.state.failed")
        ]

        for (state, identifier) in states {
            let app = askApp(state: state)
            XCTAssertTrue(
                element(identifier, in: app).waitForExistence(timeout: 3),
                "Missing Ask state \(state)"
            )
            app.terminate()
        }
    }

    func testLoadedAnswerUsesEditorialHierarchyAndAskAnotherPushesFreshComposer() {
        let app = askApp(state: "loaded")

        XCTAssertTrue(app.staticTexts["YOUR READING"].exists)
        XCTAssertTrue(app.staticTexts["A gentler kind of balance"].exists)
        XCTAssertTrue(app.staticTexts["Balance before reaction"].exists)
        XCTAssertTrue(app.staticTexts["Make room for beauty and play"].exists)
        XCTAssertTrue(element("ask.answer.try-this", in: app).exists)
        XCTAssertTrue(element("ask.answer.basis", in: app).exists)
        XCTAssertTrue(app.staticTexts["Development sample · not generated"].exists)

        app.buttons["ask.answer.ask-another"].tap()
        XCTAssertTrue(element("ask.entry.screen", in: app).waitForExistence(timeout: 3))
        XCTAssertTrue(element("ask.composer", in: app).exists)
    }

    func testComposerActionRemainsAvailableWithKeyboard() throws {
        if ProcessInfo.processInfo.environment["SIMULATOR_DEVICE_NAME"]?
            .localizedCaseInsensitiveContains("iPad") == true {
            throw XCTSkip("iPad simulator may use hardware keyboard input")
        }

        let app = askApp()
        let composer = element("ask.composer", in: app)
        XCTAssertTrue(composer.waitForExistence(timeout: 3))

        composer.tap()
        composer.typeText("What should I focus on today?")

        let action = app.buttons["ask.composer.action"]
        XCTAssertTrue(app.keyboards.firstMatch.waitForExistence(timeout: 3))
        XCTAssertTrue(action.waitForExistence(timeout: 3))
        XCTAssertTrue(action.isHittable)
    }

    func testEntrySurvivesAccessibilityContentSize() {
        let app = askApp(contentSizeCategory: "UICTContentSizeCategoryAccessibilityXXXL")

        XCTAssertTrue(element("ask.entry.screen", in: app).waitForExistence(timeout: 3))
        XCTAssertTrue(element("ask.composer", in: app).exists)
        XCTAssertTrue(app.buttons["ask.composer.action"].exists)
        XCTAssertTrue(element("ask.context", in: app).exists)
    }

    func testCaptureD5AskLightEvidence() {
        captureEvidence(appearance: "Light")
    }

    func testCaptureD5AskDarkEvidence() {
        captureEvidence(appearance: "Dark")
    }

    private func captureEvidence(appearance: String) {
        let device = ProcessInfo.processInfo.environment["SIMULATOR_DEVICE_NAME"]?
            .localizedCaseInsensitiveContains("iPad") == true ? "ipad" : "iphone"
        let style = appearance.lowercased()

        let entry = askApp(appearance: appearance)
        capture(entry, named: "d5-ask-\(device)-\(style)-entry")
        entry.terminate()

        for state in ["access", "generating", "loaded", "offline-cached"] {
            let app = askApp(state: state, appearance: appearance)
            let identifier = state == "access"
                ? "ask.access.screen"
                : state == "generating"
                    ? "ask.generating.screen"
                    : "ask.answer.screen"
            XCTAssertTrue(element(identifier, in: app).waitForExistence(timeout: 3))
            capture(app, named: "d5-ask-\(device)-\(style)-\(state)")
            app.terminate()
        }
    }

    private func askApp(
        state: String? = nil,
        appearance: String? = nil,
        contentSizeCategory: String? = nil
    ) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments += [
            "-HumayResetPersistence",
            "-HumayD2Demo"
        ]
        if let state {
            app.launchArguments += ["-HumayD5AskState", state]
        }
        if let appearance {
            app.launchArguments += ["-AppleInterfaceStyle", appearance]
        }
        if let contentSizeCategory {
            app.launchArguments += ["-UIPreferredContentSizeCategoryName", contentSizeCategory]
        }
        app.launch()

        let askShell = app.navigationBars["Ask"].waitForExistence(timeout: 2)
        if !askShell {
            XCTAssertTrue(
                app.staticTexts["main.today.wordmark"].waitForExistence(timeout: 5)
            )
            selectPrimaryDestination("Explore", in: app)
            let ask = app.buttons["explore.tool.ask"]
            XCTAssertTrue(ask.waitForExistence(timeout: 3))
            ask.tap()
        }
        addTeardownBlock {
            app.terminate()
        }
        return app
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

        let button = app.buttons[name].firstMatch
        XCTAssertTrue(button.waitForExistence(timeout: 3))
        button.tap()
    }

    private func capture(_ app: XCUIApplication, named name: String) {
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
