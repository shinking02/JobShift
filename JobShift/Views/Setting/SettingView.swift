import SwiftUI
import SwiftUIIntrospect

struct SettingView: View {
    @Environment(AppState.self) private var appState
    @State private var showSignOutAlert = false
    @State private var showProfileSheet = false
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    AppInfoView()
                }
                Section {
                    NavigationLink {
                        List {
                            Text("aa")
                        }
                            .navigationTitle("aaa")
                            .navigationBarTitleDisplayMode(.inline)
                    } label: {
                        Label("プロフィール", systemImage: "person")
                    }
                    NavigationLink {
                        Text("通知")
                    } label: {
                        Label("通知", systemImage: "bell")
                    }
                    NavigationLink {
                        Text("アカウント")
                    } label: {
                        Label("アカウント", systemImage: "key")
                    }
                }
            }
            .navigationTitle("設定")
            .customNavigationTitleWithRightIcon {
                ProfileButtonView(imageURL: appState.user?.profile?.imageURL(withDimension: 200)) {
                    showProfileSheet = true
                }
            }
        }
        .sheet(isPresented: $showProfileSheet) {
            Text("Profile Sheet")
        }
    }
}
