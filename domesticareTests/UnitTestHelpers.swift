//
//  UnitTestHelpers.swift
//  domesticare
//
//  Created by Sayuru Rehan on 2025-04-21.
//

import CoreData
import XCTest
@testable import domesticare

enum UnitTestHelpers {

    static func makeInMemoryContainer() -> NSPersistentContainer {
        let container = NSPersistentContainer(name: "domesticare")
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        container.persistentStoreDescriptions = [description]

        container.loadPersistentStores { _, error in
            XCTAssertNil(error)
        }
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return container
    }
}
