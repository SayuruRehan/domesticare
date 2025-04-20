//
//  domesticareApp.swift
//  domesticare
//
//  Created by Sayuru Rehan on 2025-04-20.
//

import SwiftUI

@main
struct domesticareApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
