import Observation
import GoogleSignIn

@Observable final class SettingViewModel {
    var appState = AppState.shared
    var showLogoutAlert = false
    var isClearedDataBase = false
    var isClearedSyncToken = false
    var isClearedLastSeenOnboardingVersion = false
    func signOutButtonTapped() {
        showLogoutAlert = true
    }
    func signOut() {
        GIDSignIn.sharedInstance.signOut()
        appState.isLoggedIn = false
        appState.firstSyncProcessed = false
    }
    func clearDataBase() {
        EventStore.shared.clear()
        isClearedDataBase = true
    }
    func clearSyncToken() {
        appState.googleSyncToken = [:]
        isClearedSyncToken = true
    }
    func clearLastSeenOnboardingVersion() {
        appState.lastSeenOnboardingVersion = ""
        isClearedLastSeenOnboardingVersion = true
    }
}
