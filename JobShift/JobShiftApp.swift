import SwiftUI
import SwiftData
import GoogleSignIn
import SwiftData

@main
struct JobShiftApp: App {
    @StateObject private var appState = AppState.shared

    let container: ModelContainer
    init() {
        print(NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true))
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
                        withAnimation {
                            if let user = user {
                                appState.user.email = user.profile?.email ?? ""
                                appState.user.imageUrl = user.profile?.imageURL(withDimension: 50)?.absoluteString ?? ""
                                appState.user.name = user.profile?.name ?? ""
                                appState.isLoggedIn = true
                                CalendarManager.shared.setUser(user)
                            } else {
                                appState.isLoggedIn = false
                            }
                            appState.loginProcessed = true
                        }
                        
                    }
                }
                .environmentObject(appState)
                .modelContainer(container)
        }
    }
}
