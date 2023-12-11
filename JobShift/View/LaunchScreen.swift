import SwiftUI
import GoogleSignIn

struct LaunchScreen: View {
    @State private var isLoading = true
    @State private var showLoginBtn = false
    @State private var fetchingEvents = false
    @State private var progressValue = 0.0
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var userState: UserState
    let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
    var body: some View {
        if isLoading || !userState.isLoggedIn {
            ZStack {
                Color(UIColor.systemBackground)
                    .ignoresSafeArea() // fill all screen
                VStack {
                    Spacer()
                    Image(colorScheme == .dark ? "icon_dark" : "icon_light")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding()
                    VStack {
                        if showLoginBtn {
                            Button(action: handleSignInButton) {
                                Image(colorScheme == .dark ? "google_login_dark" : "google_login_light")
                            }
                        }
                        if fetchingEvents {
                            ProgressView("", value: progressValue, total: 1)
                                .frame(width: 200)
                        }
                    }
                    .frame(height: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/)
                    Spacer()
                    Text("Version: \(version)")
                        .foregroundStyle(.secondary)
                }
            }
            .onAppear {
                loadCalendar()
            }
        } else {
            ContentView()
        }
    }
    private func handleSignInButton() {
        guard let presentingViewController =
                (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first?.rootViewController else { return }
        let scopes = ["https://www.googleapis.com/auth/calendar"]
        GIDSignIn.sharedInstance.signIn(withPresenting: presentingViewController, hint: nil, additionalScopes: scopes) { signInResult, error in
            if signInResult != nil {
                let profile = signInResult?.user.profile
                userState.email = profile?.email ?? ""
                userState.imageURL = profile?.imageURL(withDimension: 50)?.absoluteString ?? ""
                withAnimation {
                    userState.isLoggedIn = true
                    showLoginBtn = false
                    isLoading = true
                }
                loadCalendar()
            }
        }
    }
    private func loadCalendar() {
        progressValue = 0.0
        let calManager = GoogleCalendarManager()
        showLoginBtn = false
        fetchingEvents = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            if userState.isLoggedIn {
                withAnimation {
                    fetchingEvents = true
                }
                
                calManager.fetchCalendarIds(completion: { calendarIds in
                    let dispatchGroup = DispatchGroup()
                    
                    for id in calendarIds {
                        dispatchGroup.enter()
                        
                        calManager.fetchEventsFromCalendarId(calId: id, completion: { calendarEvents in
                            withAnimation {
                                progressValue += 1.0 / Double(calendarIds.count)
                            }
                            
                            dispatchGroup.leave()
                        })
                    }
                    
                    dispatchGroup.notify(queue: .main) {
                        withAnimation {
                            progressValue = 1
                            isLoading = false
                        }
                    }
                })
            } else {
                withAnimation {
                    showLoginBtn = true
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
