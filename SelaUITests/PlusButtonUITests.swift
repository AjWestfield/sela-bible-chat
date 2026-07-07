//
//  PlusButtonUITests.swift
//  SelaUITests
//
//  Real-tap verification: taps the Home "+" button and asserts the
//  "My Journey" settings menu is presented. Injects a genuine tap through
//  XCUITest (the app actually receives it) — unlike synthetic desktop clicks
//  which the iOS Simulator's device view ignores.
//

import XCTest

final class PlusButtonUITests: XCTestCase {

    override func setUp() {
        continueAfterFailure = false
    }

    func testPlusButtonOpensMyJourney() throws {
        let app = XCUIApplication()
        app.launchEnvironment["HAVEN_SCREEN"] = "main"   // boot straight to the main tab
        app.launch()

        // --- CONTROL: does an XCUITest tap fire SwiftUI actions in this app? ---
        let listenTab = app.buttons["Listen"]
        XCTAssertTrue(listenTab.waitForExistence(timeout: 20), "Listen tab should exist")
        listenTab.tap()
        let libraryShown = app.staticTexts["Library"].waitForExistence(timeout: 6)
        XCTAssertTrue(libraryShown,
            "CONTROL FAILED: tapping the Listen tab did not switch to the Library — XCUITest taps are not firing actions")
        app.buttons["Home"].tap()
        _ = app.staticTexts["Today's journey"].waitForExistence(timeout: 6)

        // The + button in the Home header.
        let plus = app.buttons["home-plus-button"]
        XCTAssertTrue(plus.waitForExistence(timeout: 10),
                      "The + button should be present on Home")
        let hittable = plus.isHittable

        plus.tap()   // <-- the real tap
        let journeyTitle = app.staticTexts["My Journey"]
        var appeared = journeyTitle.waitForExistence(timeout: 8)

        // Fallback: force a hit-point coordinate tap on the element.
        if !appeared {
            plus.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()
            appeared = journeyTitle.waitForExistence(timeout: 8)
        }

        if !appeared {
            let texts = app.staticTexts.allElementsBoundByIndex
                .map { $0.label }.filter { !$0.isEmpty }.prefix(30).joined(separator: " | ")
            XCTFail("MyJourney did NOT open. isHittable=\(hittable) | onscreen=[\(texts)]")
        }
    }
}
