import Foundation
import SwiftUI
import RiveRuntime

struct LaunchScreen: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var appState: AppState
    @ObservedObject var viewModel = LaunchScreenViewModel()
    let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
    
    var body: some View {
        if appState.firstSyncProcessed {
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
                    if appState.loginProcessed && !appState.isLoggedIn {
                        Button(action: viewModel.handleSignInButton) {
                            Image(colorScheme == .dark ? "google_login_dark" : "google_login_light")
                                .padding()
                                .shadow(radius: 3)
                        }
                    }
                    Text("Version: \(version)")
                    Text("3chi3chihonoka")
                }
                .foregroundStyle(.secondary)
                .onAppear() {
                    Task {
                        await viewModel.setupApp()
                    }
                }
            }
        }
    }
}

struct LaunchScreen_Previews: PreviewProvider {
    static var previews: some View {
        LaunchScreen()
            .environmentObject(AppState.shared)
    }
}
