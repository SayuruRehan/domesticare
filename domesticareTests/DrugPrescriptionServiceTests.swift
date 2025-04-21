//
//  DrugPrescriptionServiceTests.swift
//  domesticare
//
//  Created by Sayuru Rehan on 2025-04-21.
//

import XCTest
import CoreData
@testable import domesticare

final class DrugPrescriptionServiceTests: XCTestCase {

    var sut: DrugPrescriptionService!
    var ctx: NSManagedObjectContext!

    override func setUpWithError() throws {
        ctx = UnitTestHelpers.makeInMemoryContainer().viewContext
        sut = DrugPrescriptionService()
        sut.drugPrescriptionContext = ctx      // expose for tests
    }

    func testInsertFetchRemove() throws {
        let model = DrugPrescriptionModel(name: "Aspirin", dailyDosage: 2)
        sut.insertPrescription(prescription: model)

        let fetchExp = expectation(description: "fetch")
        sut.fetchDrug(for: "Aspirin") { obj in
            XCTAssertEqual(obj.value(forKey: "dailyDosage") as? Int64, 2)
            fetchExp.fulfill()
        }
        wait(for: [fetchExp], timeout: 1)

        let removeExp = expectation(description: "remove")
        sut.removeDrugBackground(drugName: "Aspirin") { ok in
            XCTAssertTrue(ok)
            removeExp.fulfill()
        }
        wait(for: [removeExp], timeout: 1)
    }
}
