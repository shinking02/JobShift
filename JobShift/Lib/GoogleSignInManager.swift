import GoogleSignIn
import RealmSwift

class GoogleSignInManager {
    private static func restorePreviousSignInAsync() async throws -> GIDGoogleUser {
        try await withCheckedThrowingContinuation { continuation in
            GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
                if error != nil {
                    continuation.resume(throwing: AppError.signin(.failedRestorePreviousSignIn))
                } else if let user = user {
                    continuation.resume(returning: user)
                } else {
                    continuation.resume(throwing: AppError.signin(.userNotFound))
                }
            }
        }
    }
    @MainActor
    private static func signInAsync(presentingviewcontroller: UIViewController, hint: String?, scopes: [String]) async throws -> GIDGoogleUser {
        try await withCheckedThrowingContinuation { continuation in
            GIDSignIn.sharedInstance.signIn(
                withPresenting: presentingviewcontroller,
                hint: hint,
                additionalScopes: scopes
            ) { signInResult, error in
                if error != nil {
                    continuation.resume(throwing: AppError.signin(.failedSignIn))
                } else if let user = signInResult?.user {
                    continuation.resume(returning: user)
                } else {
                    continuation.resume(throwing: AppError.signin(.userNotFound))
                }
            }
        }
    }
    
    static func restorePreviousSignIn() async {
        do {
            let user = try await restorePreviousSignInAsync()
            AppState.shared.user = user
            AppState.shared.isSignedIn = true
        } catch {
            print("ERROR: \(error.localizedDescription)")
        }
        AppState.shared.finishRestoreSignInProcess = true
    }
    
    static func signIn() async {
        let scopes = ["https://www.googleapis.com/auth/calendar"]
        do {
            guard let presentingViewController = await (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first?.rootViewController else {
                throw AppError.view(.notFoundPresentingViewController)
            }
            let user = try await signInAsync(presentingviewcontroller: presentingViewController, hint: nil, scopes: scopes)
            AppState.shared.user = user
            AppState.shared.isSignedIn = true
        } catch {
            print("ERROR: \(error.localizedDescription)")
        }
    }
    
    static func signOut() {
        GIDSignIn.sharedInstance.signOut()
        // swiftlint:disable force_try
        let realm = try! Realm()
        try! realm.write {
            realm.deleteAll()
        }
        // swiftlint:enable force_try
        UserDefaults.standard.set([:], forKey: UserDefaultsKeys.googleSyncTokens)
        AppState.shared.user = nil
        AppState.shared.isSignedIn = false
        AppState.shared.finishFirstSyncProcess = false
    }
}
