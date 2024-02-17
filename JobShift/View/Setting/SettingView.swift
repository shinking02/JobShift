import Foundation
import SwiftUI
import GoogleSignIn

struct SettingView: View {
    @EnvironmentObject var appState: AppState
    @State private var showLogoutAlert: Bool = false
    @State private var isDevelopperMode: Bool = UserDefaultsData.shared.getIsDevelopperMode()
    @State private var syncTokens = UserDefaultsData.shared.getGoogleSyncTokens()
    @State private var isCleardDataBase: Bool = false
    @State private var isCleardSyncTokens: Bool = false
    
    var body: some View {
        List {
            Section {
                HStack {
                    AsyncImage(url: URL(string: appState.user.imageUrl)) { image in
                        image.resizable()
                           .clipShape(Circle())
                   } placeholder: {
                       Image(systemName: "person.crop.circle")
                           .resizable()
                   }
                   .frame(width: 50, height: 50)
                    VStack(alignment: .leading) {
                        Text(appState.user.name)
                            .font(.title2)
                        Text(appState.user.email)
                            .foregroundStyle(.secondary)
                    }
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
                Toggle("開発者モード", isOn: $isDevelopperMode.animation())
                    .onChange(of: isDevelopperMode) {
                        UserDefaultsData.shared.setIsDevelopperMode(isDevelopperMode)
                    }
            }
            if isDevelopperMode {
                if !syncTokens.isEmpty {
                    Section(header: Text("SYNCTOKEN")) {
                        ForEach(syncTokens.sorted(by: >), id: \.key) { key, value in
                            Text(key)
                                .lineLimit(1)
                            Text(value)
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                                .font(.caption2)
                        }
                    }
                }
                Section {
                    Button(action: {
                        EventStore.shared.clear()
                        isCleardDataBase = true
                    } ) {
                        Text("Clear DataBase")
                    }.disabled(isCleardDataBase)
                    Button(action: {
                        syncTokens = [:]
                        isCleardSyncTokens = true
                        UserDefaultsData.shared.setGoogleSyncTokens(syncTokens)
                    } ) {
                        Text("Clear SyncTokens")
                    }.disabled(isCleardSyncTokens)
                }
            }
            Section {
                HStack {
                    Spacer()
                    Button("サインアウト") {
                        showLogoutAlert = true
                    }
                    .alert("サインアウトしますか？", isPresented: $showLogoutAlert) {
                        Button("キャンセル", role: .cancel) {}
                        Button("サインアウト", role: .destructive) {
                            GIDSignIn.sharedInstance.signOut()
                            appState.user = User(email: "", imageUrl: "", name:
                                                    "")
                            withAnimation {
                                appState.firstSyncProcessed = false
                                appState.isLoggedIn = false
                            }
                        }
                    } message: {
                        Text("バイトのデータは失われません")
                    }
                    .foregroundColor(.red)
                    Spacer()
                }
            }
        }
    }
}
