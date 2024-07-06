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
                    NavigationLink(destination: JobSettingView()) {
                        Label("バイト", systemImage: "pencil.and.list.clipboard")
                    }
                    NavigationLink(destination: CalendarSettingView()) {
                        Label("カレンダー", systemImage: "calendar")
                    }
                    NavigationLink(destination: NotificationSettingView()) {
                        Label("通知", systemImage: "bell")
                    }
                }
                Section(footer:
                    Text("© 2024 Shin Kawakami")
                    .frame(maxWidth: .infinity, alignment: .center)
                    .foregroundStyle(.secondary)
                ) {
                    NavigationLink(destination: SubmitIssueView()) {
                        Label("要望", systemImage: "text.bubble")
                    }
                    NavigationLink(
                        destination: LicenseListView()
                            .navigationTitle("ライセンス")
                            .navigationBarTitleDisplayMode(.inline)
                    ) {
                        Label("ライセンス", systemImage: "book.and.wrench")
                    }
                    NavigationLink(destination: DeveloperSettingView()) {
                        Label("開発者向け設定", systemImage: "wrench.and.screwdriver")
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
