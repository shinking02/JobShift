import Foundation
import RiveRuntime
import SwiftUI

struct LaunchScreen: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var viewModel = LaunchScreenViewModel()
    let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
    
    var body: some View {
        Group {
            if viewModel.appState.firstSyncProcessed {
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
                        if viewModel.appState.loginRestored && !viewModel.appState.isLoggedIn {
                            Button(action: viewModel.signInButtonTapped) {
                                Image(colorScheme == .dark ? "google_login_dark" : "google_login_light")
                                    .padding()
                                    .shadow(radius: 3)
                            }
                        }
                        Text("Version: \(version)")
                        Text("3chi3chihonoka")
                    }
                    .animation(.default, value: viewModel.appState.isLoggedIn)
                    .foregroundStyle(.secondary)
                    .onAppear {
                        Task {
                            await viewModel.setupApp()
                        }
                    }
                }
            }
        }
        .animation(.default, value: viewModel.appState.firstSyncProcessed)
    }
}
