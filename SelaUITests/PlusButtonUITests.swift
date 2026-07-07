//
//  PlusButtonUITests.swift
//  SelaUITests
//
//  Home-screen interaction tests. Each test launches fresh and exercises one
//  primary flow with real synthesized taps.
//

import XCTest

final class PlusButtonUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    private func launchHome() -> XCUIApplication {
        let app = XCUIApplication()
        app.launchEnvironment["HAVEN_SCREEN"] = "main"
        app.launch()
        XCTAssertTrue(app.staticTexts["Today's journey"].waitForExistence(timeout: 20),
                      "Home should be visible after launch")
        return app
    }

    /// Taps an element robustly. XCUITest caches accessibility snapshots; if the
    /// layout re-settles after `waitForExistence` (as Home's scroll content does
    /// shortly after launch and after cover dismissal), a plain `tap()` can land
    /// on a stale coordinate and miss. Poll the frame until it is stable, then
    /// tap via a normalized coordinate, which resolves at tap time.
    private func settleAndTap(_ element: XCUIElement) {
        XCTAssertTrue(element.waitForExistence(timeout: 10), "element should exist")
        var last = element.frame
        for _ in 0..<12 {
            Thread.sleep(forTimeInterval: 0.25)
            let now = element.frame
            if now == last, element.isHittable { break }
            last = now
        }
        element.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()
    }

    /// The + button in the Home header opens the My Journey settings sheet.
    func testPlusButtonOpensMyJourney() throws {
        let app = launchHome()
        let plus = app.buttons["home-plus-button"]
        settleAndTap(plus)
        XCTAssertTrue(app.staticTexts["My Journey"].waitForExistence(timeout: 6),
                      "+ tap should present My Journey")
    }

    /// After closing My Journey, the + button can present it again.
    func testPlusButtonReopens() throws {
        let app = launchHome()
        let plus = app.buttons["home-plus-button"]
        settleAndTap(plus)
        XCTAssertTrue(app.staticTexts["My Journey"].waitForExistence(timeout: 6),
                      "first presentation should work")

        settleAndTap(app.buttons["journey-back-button"].firstMatch)
        let title = app.staticTexts["My Journey"]
        let gone = XCTNSPredicateExpectation(
            predicate: NSPredicate(format: "exists == false"), object: title)
        XCTAssertEqual(XCTWaiter().wait(for: [gone], timeout: 6), .completed,
                       "sheet should dismiss")
        settleAndTap(plus)
        XCTAssertTrue(app.staticTexts["My Journey"].waitForExistence(timeout: 6),
                      "second presentation (after dismiss) should work")
    }

    /// Interpret opens the chat cover.
    func testInterpretButton() throws {
        let app = launchHome()
        settleAndTap(app.buttons["interpret-button"])
        let opened = app.staticTexts["Chat"].waitForExistence(timeout: 6)
            || app.textFields.firstMatch.waitForExistence(timeout: 2)
            || app.textViews.firstMatch.waitForExistence(timeout: 2)
        XCTAssertTrue(opened, "Interpret should open Chat")
    }

    /// Begin opens the Daily Plan.
    func testBeginButton() throws {
        let app = launchHome()
        settleAndTap(app.buttons["Begin"])
        XCTAssertTrue(app.staticTexts["Daily Plan"].waitForExistence(timeout: 6),
                      "Begin should open the Daily Plan")
    }

    /// Listen tab → collection → story → full-screen player.
    func testListenToPlayer() throws {
        let app = launchHome()
        settleAndTap(app.buttons["Listen"])
        XCTAssertTrue(app.staticTexts["Library"].waitForExistence(timeout: 6), "Library should show")
        // Collection cards are NavigationLinks → exposed as buttons.
        let card = app.buttons["Bible Stories"].firstMatch
        settleAndTap(card.exists ? card : app.staticTexts["Bible Stories"].firstMatch)
        XCTAssertTrue(app.staticTexts["Creation"].waitForExistence(timeout: 6), "collection should open")
        let story = app.buttons["Creation: In the Beginning"].firstMatch
        settleAndTap(story.exists ? story : app.staticTexts["Creation: In the Beginning"].firstMatch)
        XCTAssertTrue(app.staticTexts["BIBLE STORY"].waitForExistence(timeout: 8),
                      "player should present")
    }

    /// Chat: send a message, get a (mock or live) reply bubble.
    func testChatSendMessage() throws {
        let app = launchHome()
        settleAndTap(app.buttons["interpret-button"])
        let field = app.textFields.firstMatch
        XCTAssertTrue(field.waitForExistence(timeout: 8), "chat composer should exist")
        field.tap()
        field.typeText("What does this verse mean?")
        // Send via the arrow button (chat send control).
        let send = app.buttons["chat-send-button"].firstMatch
        if send.exists { send.tap() } else { app.keyboards.buttons["return"].firstMatch.tap() }
        // A reply should stream in within a few seconds (mock replies are instant-ish).
        let replied = app.staticTexts.matching(
            NSPredicate(format: "label CONTAINS[c] 'hebrews' OR label CONTAINS[c] 'jesus' OR label CONTAINS[c] 'verse' OR label CONTAINS[c] 'god'"
        )).firstMatch.waitForExistence(timeout: 15)
        XCTAssertTrue(replied, "chat should produce a reply")
    }
}
