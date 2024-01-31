//
//  JobShiftApp.swift
//  JobShift
//
//  Created by 川上真 on 2023/12/10.
//

import SwiftUI
import SwiftData
import GoogleSignIn
import SwiftData

@main
struct JobShiftApp: App {
    @StateObject private var userState = UserState()
    @StateObject var events = EventStore()
    let container: ModelContainer
    init() {
        do {
            container = try ModelContainer(for: Job.self, OneTimeJob.self, migrationPlan: JobMigrationPlan.self)
        } catch {
            fatalError("Failed to initialize model container.")
        }
    }
    var body: some Scene {
        WindowGroup {
            LaunchScreen()
                .onOpenURL { url in
                    GIDSignIn.sharedInstance.handle(url)
                }
                .onAppear {
                    GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
                        if user != nil {
                            userState.email = user?.profile?.email ?? ""
                            userState.imageURL = user?.profile?.imageURL(withDimension: 50)?.absoluteString ?? ""
                            userState.isLoggedIn = true
                        } else {
                            userState.isLoggedIn = false
                        }
                    }
                }
                .environmentObject(userState)
                .environmentObject(events)
                .modelContainer(container)
        }
    }
}
