//
//  JobShiftApp.swift
//  JobShift
//
//  Created by 川上真 on 2023/12/10.
//

import SwiftUI
import SwiftData
import GoogleSignIn

@main
struct JobShiftApp: App {
    @StateObject private var userState = UserState()
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
                .onOpenURL { url in
                    GIDSignIn.sharedInstance.handle(url)
                }
                .onAppear {
                    GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
                        if user != nil {
                            userState.email = user?.profile?.email ?? ""
                            userState.imageURL = user?.profile?.imageURL(withDimension: 60)?.absoluteString ?? ""
                            userState.isLoggedIn = true
                        } else {
                            userState.isLoggedIn = false
                        }
                    }
                }
                .environmentObject(userState)
        }
        .modelContainer(sharedModelContainer)
    }
}

class UserState: ObservableObject {
    @Published var email: String = ""
    @Published var imageURL: String = ""
    @Published var isLoggedIn: Bool = false
}
