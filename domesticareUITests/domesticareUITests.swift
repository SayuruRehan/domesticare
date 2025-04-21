//
//  domesticareUITests.swift
//  domesticareUITests
//
//  Created by Sayuru Rehan on 2025-04-21.
//

import XCTest

final class domesticareUITests: XCTestCase {

    let app = XCUIApplication()

    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launchArguments.append("--uitesting")
        app.launch()
    }

    func testAddInventoryItem() throws {
        // Assumes you’re on Inventory tab by default
        app.navigationBars.buttons["Add"].tap()

        let nameField = app.textFields.element(boundBy: 0)
        nameField.tap()
        nameField.typeText("Test Drug")

        let qtyField = app.textFields.element(boundBy: 1)
        qtyField.tap()
        qtyField.typeText("5")

        // Skip photo, hit Save
        app.navigationBars.buttons["Save"].tap()

        // Grid should now contain a cell labelled “Test Drug”
        XCTAssertTrue(app.staticTexts["Test Drug"].waitForExistence(timeout: 2))
    }
}
