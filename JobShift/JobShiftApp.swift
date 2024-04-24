import GoogleSignIn
import SwiftUI

@main
struct JobShiftApp: App {
    @State var appState: AppState = .shared
    
    var body: some Scene {
        WindowGroup {
            
            LaunchScreenView()
                .onOpenURL { url in
                    GIDSignIn.sharedInstance.handle(url)
                }
                .onAppear {
                    Task {
                        await GoogleSignInManager.restorePreviousSignIn()
                    }
                }
                .environment(appState)
        }
    }
}
