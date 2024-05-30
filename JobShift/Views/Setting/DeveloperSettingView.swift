import RealmSwift
import SwiftUI

// swiftlint:disable force_try

struct DeveloperSettingView: View {
    @State private var clearedLastSeenOBVersion = false
    @State private var clearedGoogleSyncToken = false
    @State private var clearedRealmDatabase = false
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    NavigationLink(destination: UserDefaultsView()) {
                        Label("UserDefaults", systemImage: "doc")
                    }
                    NavigationLink(destination: RealmDataBaseView()) {
                        Label("RealmDataBase", systemImage: "externaldrive")
                    }
                }
                Section {
                    Button {
                        Storage.setLastSeenOnboardingVersion("")
                        clearedLastSeenOBVersion = true
                    } label: {
                        Text("Clear Last Seen OB Version")
                    }
                    .disabled(clearedLastSeenOBVersion)
                    Button {
                        UserDefaults.standard.set([:], forKey: UserDefaultsKeys.googleSyncTokens)
                        clearedGoogleSyncToken = true
                    } label: {
                        Text("Clear Next SyncToken")
                    }
                    .disabled(clearedGoogleSyncToken)
                    Button {
                        let realm = try! Realm()
                        try! realm.write {
                            realm.deleteAll()
                        }
                        clearedRealmDatabase = true
                    } label: {
                        Text("Clear Realm Database")
                    }
                    .disabled(clearedRealmDatabase)
                }
                .tint(.red)
                Section {
                    Button {
                        UIControl().sendAction(#selector(URLSessionTask.suspend), to: UIApplication.shared, for: nil)
                        Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false) { _ in
                            exit(0)
                        }
                    } label: {
                        Text("Kill App")
                    }
                }
                .tint(.red)
                
            }
            .navigationTitle("開発者向け設定")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// swiftlint:enable force_try
