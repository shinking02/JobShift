import Foundation
import SwiftUI
import GoogleSignIn

struct SettingView: View {
    @State private var logoutAlert = false
    @EnvironmentObject var userState: UserState
    @Environment(\.colorScheme) var colorScheme
    let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    HStack {
                        AsyncImage(url: URL(string: userState.imageURL)) { image in
                            image.resizable()
                        } placeholder: {
                            ProgressView()
                        }
                            .frame(width: 40, height: 40)
                            .clipShape(Circle())
                        Text(userState.email)
                            .padding(.horizontal)
                    }
                }
                Section {
                    NavigationLink(destination: EmptyView()) {
                        Text("カレンダー")
                    }
                    NavigationLink(destination: EmptyView()) {
                        Text("バイト")
                    }
                }
                Section {
                    HStack {
                        Spacer()
                        Button("ログアウト") {
                            logoutAlert = true
                        }
                        .alert("確認", isPresented: $logoutAlert) {
                            Button("キャンセル", role: .cancel) {}
                            Button("ログアウト", role: .destructive) {
                                GIDSignIn.sharedInstance.signOut()
                                userState.imageURL = ""
                                userState.email = ""
                                withAnimation {
                                    userState.isLoggedIn = false
                                }
                            }
                        } message: {
                            Text("ログアウトしますか？")
                        }
                        .foregroundColor(.red)
                        Spacer()
                    }
                }
                Section(
                    footer:
                        HStack{
                            Spacer()
                            Image(colorScheme == .dark ? "github_dark" : "github_light")
                                .resizable()
                                .scaledToFill()
                                .frame(width: 18, height: 18, alignment: .center)

                            Link("Github Repository",
                                 destination: URL(string: "https://github.com/shinking02/JobShift")!)
                            Spacer()
                        }
                ) {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text(version)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("設定")
        }
    }
}
