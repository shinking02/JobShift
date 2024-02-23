import Foundation
import GoogleSignIn
import SwiftUI

class SettingViewModel: ObservableObject {
    @Published var isDevelopperMode: Bool
    @Published var syncTokens: [String: String]
    @Published var isCleardDataBase: Bool
    @Published var isCleardSyncTokens: Bool
    
    init() {
        self.isDevelopperMode = UserDefaultsData.shared.getIsDevelopperMode()
        self.syncTokens = UserDefaultsData.shared.getGoogleSyncTokens()
        self.isCleardDataBase = false
        self.isCleardSyncTokens = false
    }
    
    func clearDataBase() {
        EventStore.shared.clear()
        self.isCleardDataBase = true
    }
    
    func clearSyncTokens() {
        self.syncTokens = [:]
        self.isCleardSyncTokens = true
        UserDefaultsData.shared.setGoogleSyncTokens(self.syncTokens)
    }
    
    func handleChangeDevelopperMode() {
        UserDefaultsData.shared.setIsDevelopperMode(self.isDevelopperMode)
    }
    
    func signOut(appState: AppState) {
        GIDSignIn.sharedInstance.signOut()
        appState.user = User(email: "", imageUrl: "", name: "")
        withAnimation {
            appState.firstSyncProcessed = false
            appState.isLoggedIn = false
        }
    }
}
