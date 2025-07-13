//
//  GitSearchApp.swift
//  GitSearch
//
//  Created by Suresh Kumar on 13/07/25.
//

import SwiftUI

@main
struct GitSearchApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
