import Foundation
import SwiftUI
import GoogleSignIn

struct SettingView: View {
    @State private var logoutAlert = false
    @EnvironmentObject var userState: UserState
    
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
            }
            .navigationTitle("設定")
        }
    }
}
