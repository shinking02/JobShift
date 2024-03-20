import SwiftUI
import GoogleSignIn

struct LaunchScreen: View {
    @State private var isLoading = true
    @State private var showLoginBtn = false
    @State private var fetchingEvents = false
    @State private var progressValue = 0.0
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var userState: UserState
    @EnvironmentObject var eventStore: EventStore
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
                    Text("3chi3chihonoka")
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
        let calManager = GoogleCalendarManager.shared
        showLoginBtn = false
        fetchingEvents = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { // ログインの復元後(1秒以内には終わる)、認証情報をシングルトンインスタンスにセット
            if let user = GIDSignIn.sharedInstance.currentUser {
                GoogleCalendarManager.shared.setUser(user: user)
            }
            if userState.isLoggedIn {
                withAnimation {
                    fetchingEvents = true
                    progressValue += 0.1
                }
                var receivedEvents: [Event] = []
                calManager.fetchCalendarIds(completion: { calendars in
                    let dispatchGroup = DispatchGroup()
                    let disableCalIds = UserDefaults.standard.array(forKey: UserDefaultsKeys.disabledCalIds) as? [String] ?? []
                    let filterdCalendars = calendars.filter { cal in
                        guard let id = cal.identifier else { return false }
                        return !disableCalIds.contains(id)
                    }
                    userState.calendars = calendars
                    userState.selectedCalendars = filterdCalendars
                    let mainCalId = UserDefaults.standard.string(forKey: UserDefaultsKeys.mainCalId)
                    userState.mainCal = calendars.first { $0.identifier == mainCalId } ?? calendars[0]
                    for cal in filterdCalendars {
                        dispatchGroup.enter()
                        calManager.fetchEventsFromCalendarId(calId: cal.identifier ?? "", completion: { events in
                            if let events = events {
                                receivedEvents.append(contentsOf: events.map { gEvent in
                                    return Event(calId: cal.identifier ?? "", gEvent: gEvent)
                                })
                            }
                            withAnimation {
                                progressValue += 0.9 / Double(filterdCalendars.count)
                            }
                            dispatchGroup.leave()
                        })
                    }
                    
                    dispatchGroup.notify(queue: .main) {
                        eventStore.addEvents(events: receivedEvents)
                        SalaryManager.shared.setEventStore(eventStore: eventStore)
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
