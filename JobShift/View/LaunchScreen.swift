import SwiftUI
import GoogleSignIn

struct LaunchScreen: View {
    @State private var isLoading = true
    @State private var showLoginBtn = false
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var userState: UserState
    let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
    var body: some View {
        if isLoading {
            ZStack {
                Color(UIColor.systemBackground)
                    .ignoresSafeArea() // fill all screen
                VStack {
                    Spacer()
                    Image(colorScheme == .dark ? "icon_dark" : "icon_light")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding()
                    if (showLoginBtn) {
                        Button(action: handleSignInButton) {
                            Image(colorScheme == .dark ? "google_login_dark" : "google_login_light")
                        }
                    }
                    Spacer()
                    Text("Version: \(version)")
                        .foregroundStyle(.secondary)
                }
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) { // 起動時のログイン状態の復元を待つ
                    if (userState.isLoggedIn) {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            withAnimation {
                                isLoading = false
                            }
                        }
                    } else {
                        withAnimation {
                            showLoginBtn = true
                        }
                    }
                }
            }
        } else {
            ContentView()
        }
    }
    private func handleSignInButton() {
        guard let presentingViewController =
                (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first?.rootViewController else { return }
        let scopes = ["https://www.googleapis.com/auth/calendar.events"]
        GIDSignIn.sharedInstance.signIn(withPresenting: presentingViewController, hint: nil, additionalScopes: scopes) { signInResult, error in
            if signInResult != nil {
                let profile = signInResult?.user.profile
                userState.email = profile?.email ?? ""
                userState.imageURL = profile?.imageURL(withDimension: 50)?.absoluteString ?? ""
                withAnimation {
                    userState.isLoggedIn = true
                    isLoading = false
                }
            }
        }
    }
}

struct LaunchScreen_Previews: PreviewProvider {
    static var previews: some View {
        LaunchScreen()
    }
}
