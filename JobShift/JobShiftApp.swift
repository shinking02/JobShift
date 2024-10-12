import GoogleSignIn
import SwiftData
import SwiftUI

@main
struct JobShiftApp: App {
    @State private var appState = AppState.shared

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
            List {
                Text("Job Schema Test")
            }
            .modelContainer(container)  
        }
    }
}
