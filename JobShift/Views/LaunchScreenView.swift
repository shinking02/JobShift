import RiveRuntime
import SwiftUI

struct LaunchScreenView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(AppState.self) private var appState
    @State private var finishFirstSync = false
    private let version: String = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
    
    var body: some View {
        Group {
            if appState.finishFirstSyncProcess && appState.isSignedIn {
                ContentView()
            } else {
                ZStack {
                    RiveViewModel(fileName: "shapes").view()
                        .ignoresSafeArea()
                        .blur(radius: 60)
                        .background(
                            Image("spline")
                                .blur(radius: 50)
                                .offset(x: 200, y: 100)
                        )
                    VStack {
                        Image(colorScheme == .light ? "icon_light" : "icon_dark")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .padding(80)
                        Spacer()
                        if appState.finishRestoreSignInProcess && !appState.isSignedIn {
                            Button {
                                Task {
                                    await GoogleSignInManager.signIn()
                                    await syncFromGoogleCalendar()
                                }
                            } label: {
                                Image(colorScheme == .dark ? "google_login_dark" : "google_login_light")
                                    .padding()
                                    .shadow(radius: 3)
                            }
                        }
                        Text("Version: \(version)")
                        Text("3chi3chihonoka")
                    }
                    .foregroundStyle(.secondary)
                }
                .onAppear {
                    Task { await syncFromGoogleCalendar() }
                }
            }
        }
        .animation(.default, value: appState.finishFirstSyncProcess)
        .animation(.default, value: appState.isSignedIn)
        .animation(.default, value: appState.finishRestoreSignInProcess)
    }
    
    private func syncFromGoogleCalendar() async {
        Task {
            while !appState.finishRestoreSignInProcess {
                do {
                    try await Task.sleep(millisecond: 200)
                } catch {
                    print("ERROR: \(error.localizedDescription)")
                }
            }
            if !appState.isSignedIn {
                return
            }
            await CalendarManager.shared.syncGoogleCalendar(skipSyncCalendarList: false)
            appState.finishFirstSyncProcess = true
        }
    }
}
