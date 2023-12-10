//
//  JobShiftApp.swift
//  JobShift
//
//  Created by 川上真 on 2023/12/10.
//

import SwiftUI
import SwiftData

@main
struct JobShiftApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            LaunchScreen()
        }
        .modelContainer(sharedModelContainer)
    }
}
