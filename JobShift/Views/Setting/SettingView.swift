import LicenseList
import SwiftUI

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
                        Text("JobSettingView")
                    } label: {
                        Label("バイト", systemImage: "pencil.and.list.clipboard")
                    }
                    NavigationLink {
                        CalendarSettingView()
                    } label: {
                        Label("カレンダー", systemImage: "calendar")
                    }
                    NavigationLink {
                        NotificationSettingView()
                    } label: {
                        Label("通知", systemImage: "bell")
                    }
                }
                Section(footer:
                    Text("© 2024 Shin Kawakami")
                    .frame(maxWidth: .infinity, alignment: .center)
                    .foregroundStyle(.secondary)
                ) {
                    NavigationLink {
                        DeveloperSettingView()
                    } label: {
                        Label("開発者向け情報", systemImage: "wrench.and.screwdriver")
                    }
                    NavigationLink {
                        LicenseListView()
                            .navigationTitle("ライセンス")
                            .navigationBarTitleDisplayMode(.inline)
                    } label: {
                        Label("ライセンス", systemImage: "book.and.wrench")
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
            ProfileSheetView()
        }
    }
}
