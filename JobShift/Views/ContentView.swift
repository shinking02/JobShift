import SwiftUI

struct ContentView: View {
    @State private var selectedTab: Tab = .shift
    @State private var isWelcomePresented = false
    @Environment(\.openURL) private var openURL
    private let AVAIABLE_OB_VERSION = "2"
    
    var body: some View {
        TabView(selection: $selectedTab) {
            ShiftView(isWelcomePresented: $isWelcomePresented)
                .tag(Tab.shift)
                .tabItem {
                    Label(Tab.shift.rawValue, systemImage: Tab.shift.symbol)
                }
                .toolbarBackground(.visible, for: .tabBar)
                .toolbarBackground(.bar, for: .tabBar)
            SalaryView()
                .tag(Tab.salary)
                .tabItem {
                    Label(Tab.salary.rawValue, systemImage: Tab.salary.symbol)
                }
            SettingView()
                .tag(Tab.setting)
                .tabItem {
                    Label(Tab.setting.rawValue, systemImage: Tab.setting.symbol)
                }
        }
        .onAppear {
            isWelcomePresented = Storage.getLastSeenOnboardingVersion() != AVAIABLE_OB_VERSION
        }
        .sheet(
            isPresented: $isWelcomePresented,
            onDismiss: {
                Storage.setLastSeenOnboardingVersion(AVAIABLE_OB_VERSION)
            },
            content: {
                OBWelcomeView(
                    title: "ようこそJobShiftへ",
                    detailText: "リファクタ、動作の改善を行いました。",
                    bulletedListItems: [
                        .init(title: "給料日", description: "給料日の月を設定できるようになりました。デフォルトでは翌月になっているため確認してみてください。", symbolName: "yensign"),
                        .init(title: "動作の安定", description: "全体的な動作の改善を行いました。不具合等あれば報告お願いします。", symbolName: "swift"),
                        .init(title: "注意", description: "最低限の機能でリリースしています。以前のバージョンまで存在した機能は今後実装予定です。", symbolName: "hammer.fill")
                    ],
                    boldButtonItem: .init(title: "続ける", action: {
                        isWelcomePresented = false
                    }),
                    linkButtonItem: .init(title: "詳細", action: { openURL(URL(string: "https://github.com/shinking02/JobShift/pull/77")!) })
                )
            }
        )
    }
}
