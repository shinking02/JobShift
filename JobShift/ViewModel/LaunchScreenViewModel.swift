import Observation
import GoogleSignIn

@Observable final class LaunchScreenViewModel {
    var appState = AppState.shared
    
    func signInButtonTapped() {
        guard let presentingViewController = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first?.rootViewController else { return }
        let scopes = ["https://www.googleapis.com/auth/calendar"]
        GIDSignIn.sharedInstance.signIn(withPresenting: presentingViewController, hint: nil, additionalScopes: scopes) { signInResult, error in
            if let signInResult = signInResult {
                let profile = signInResult.user.profile
                self.appState.user.email = profile?.email ?? ""
                self.appState.user.imageUrl = profile?.imageURL(withDimension: 50)?.absoluteString ?? ""
                self.appState.user.name = profile?.name ?? ""
                CalendarManager.shared.setUser(signInResult.user)
                self.appState.isLoggedIn = true
                self.appState.loginRestored = true
            }
            Task {
                await self.setupApp()
            }
        }
    }
    
    func setupApp() async {
        let calendarManager = CalendarManager.shared
        let eventStore = EventStore.shared
        // Wait until appState.loginProcessed becomes true
        while !appState.loginRestored {
            try! await Task.sleep(nanoseconds: 1_000_000_000) // Sleep for 1 second
        }
        if !appState.isLoggedIn {
            return
        }
        // If Google account has been switched, initialize the settings.
        if appState.user.email != appState.lastSyncedEmail {
            eventStore.clear()
            appState.googleSyncToken = [:]
            appState.lastSeenOnboardingVersion = ""
        }
        appState.userCalendars = await calendarManager.getUserCalendar().sorted(by: { $0.name < $1.name })
        await calendarManager.sync()
        appState.lastSyncedEmail = appState.user.email
        appState.firstSyncProcessed = true
    }
}
