import SwiftUI

struct DeveloperSettingView: View {
    @State private var clearedLastSeenOBVersion = false
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    NavigationLink(destination: UserDefaultsView()) {
                        Label("UserDefaults", systemImage: "externaldrive")
                    }
                }
                Section {
                    Button {
                        Storage.setLastSeenOnboardingVersion("")
                        withAnimation {
                            clearedLastSeenOBVersion = true
                        }
                    } label: {
                        Text("Clear Last Seen OB Version")
                    }
                    .tint(.red)
                    .disabled(clearedLastSeenOBVersion)
                }
                
            }
            .navigationTitle("開発者向け設定")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
