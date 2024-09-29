import GoogleSignIn
import Observation

@Observable
final class AppState {
    static let shared = AppState()
    private init() {}
    
    var isSignedIn: Bool = false
    var user: GIDGoogleUser?
    var finishFirstSyncProcess: Bool = false
    var finishRestoreSignInProcess: Bool = false
}
