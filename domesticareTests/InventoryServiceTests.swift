//
//  InventoryServiceTests.swift
//  domesticare
//
//  Created by Sayuru Rehan on 2025-04-21.
//

import XCTest
import CoreData
@testable import domesticare

final class InventoryServiceTests: XCTestCase {

    var sut: InventoryService!
    var ctx: NSManagedObjectContext!

    override func setUpWithError() throws {
        ctx = UnitTestHelpers.makeInMemoryContainer().viewContext
        sut = InventoryService()
        //sut.drugInventoryContext = ctx         // ← expose via `internal` for tests
    }

    func testSaveAndFetch() throws {
        let model = DrugInventoryModel(
            uuid: UUID(),
            snapshot: nil,
            name: "Aspirin",
            expirationDate: .now,
            originalQuantity: 20,
            remainingQuantity: 20
        )
        sut.saveDrugInventory(drugInventory: model)

        let exp = expectation(description: "fetch")
        sut.fetchInventoryDetailsBackground(fetch_offset: nil) { result in
            XCTAssertEqual(result.count, 1)
            let object = result.first!
            XCTAssertEqual(object.value(forKey: "name") as? String, "Aspirin")
            exp.fulfill()
        }
        waitForExpectations(timeout: 1)
    }

    func testUpdateRemainingQuantity() throws {
        let id = UUID()
        sut.saveDrugInventory(drugInventory: .init(
            uuid: id,
            snapshot: nil,
            name: "Vitamin C",
            expirationDate: .now,
            originalQuantity: 30,
            remainingQuantity: 30))

        let exp = expectation(description: "update")
        sut.updateRemainingQuantity(for: id, newQuantity: 10) { ok in
            XCTAssertTrue(ok)
            self.sut.fetchInventoryDetailsBackground(fetch_offset: nil) { result in
                let qty = result.first?.value(forKey: "remainingQuantity") as? Int64
                XCTAssertEqual(qty, 10)
                exp.fulfill()
            }
        }
        waitForExpectations(timeout: 1)
    }

    func testRemoveInventory() throws {
        let id = UUID()
        sut.saveDrugInventory(drugInventory: .init(
            uuid: id,
            snapshot: nil,
            name: "Ibuprofen",
            expirationDate: .now,
            originalQuantity: 15,
            remainingQuantity: 15))

        let exp = expectation(description: "remove")
        sut.removeDrugInventory(uuid: id) { ok in
            XCTAssertTrue(ok)
            self.sut.fetchInventoryDetailsBackground(fetch_offset: nil) { result in
                XCTAssertTrue(result.isEmpty)
                exp.fulfill()
            }
        }
        waitForExpectations(timeout: 1)
    }
}
