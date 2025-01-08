//
//  EWA_AND_NVQ_E_PORTFOLIOUITests.swift
//  EWA AND NVQ E PORTFOLIOUITests
//
//  Created by WAYNE WRIGHT on 18/12/2024.
//

import XCTest

final class EWA_AND_NVQ_E_PORTFOLIOUITests: XCTestCase {
    let app = XCUIApplication()
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launch()
    }
    
    func testSwipeActions() throws {
        // Wait for evidence list to load
        let evidenceList = app.collectionViews["EvidenceList"]
        XCTAssertTrue(evidenceList.waitForExistence(timeout: 5))
        
        // Ensure we have items before testing swipe
        if evidenceList.cells.count > 0 {
            let firstCell = evidenceList.cells.element(boundBy: 0)
            firstCell.swipeLeft()
            
            // Verify swipe action buttons
            let hideButton = app.buttons["Hide"]
            XCTAssertTrue(hideButton.waitForExistence(timeout: 2))
        }
    }
}
