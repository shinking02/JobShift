import Foundation
import SwiftUI
import GoogleSignIn

class LaunchScreenViewModel: ObservableObject {
    private let appState = AppState.shared
    
    func handleSignInButton() {
        guard let presentingViewController =
                (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first?.rootViewController else { return }
        let scopes = ["https://www.googleapis.com/auth/calendar"]
        GIDSignIn.sharedInstance.signIn(withPresenting: presentingViewController, hint: nil, additionalScopes: scopes) { signInResult, error in
            if let signInResult = signInResult {
                let profile = signInResult.user.profile
                self.appState.user.email = profile?.email ?? ""
                self.appState.user.imageUrl = profile?.imageURL(withDimension: 50)?.absoluteString ?? ""
                self.appState.user.name = profile?.name ?? ""
                CalendarManager.shared.setUser(signInResult.user)
                withAnimation {
                    self.appState.isLoggedIn = true
                    self.appState.loginProcessed = true
                }
            }
            Task {
                await self.setupApp()
            }
        }
    }
    
    func setupApp() async {
        let calendarManager = CalendarManager.shared
        let userDefaultsData = UserDefaultsData.shared
        // Wait until appState.loginProcessed becomes true
        while !appState.loginProcessed {
            try! await Task.sleep(nanoseconds: 1_000_000_000) // Sleep for 1 second
        }
        if !appState.isLoggedIn {
            return
        }
        // If Google account has been switched, initialize the settings.
        if appState.user.email != userDefaultsData.getLastSyncedEmail() {
            userDefaultsData.clearAll()
            CalendarManager.shared.clear()
        }
        
        let apiCalendars = Set(await calendarManager.getUserCalendar())
        let activeCalendars = Set(userDefaultsData.getActiveCalendars())
        if activeCalendars.isEmpty {
            userDefaultsData.setActiveCalendars(Array(apiCalendars))
        } else {
            let newActiveCalendars = apiCalendars.intersection(activeCalendars)
            userDefaultsData.setActiveCalendars(Array(newActiveCalendars))
        }
        let sortedApiCalendars = Array(apiCalendars).sorted { $0.name < $1.name }
        userDefaultsData.setAllCalendars(sortedApiCalendars)
        
        await calendarManager.sync()
        userDefaultsData.setLastSyncedEmail(appState.user.email)
        DispatchQueue.main.async {
            withAnimation {
                self.appState.firstSyncProcessed = true
            }
        }
    }
}
