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
                    detailText: "全体的な動作の改善を行いました。",
                    bulletedListItems: [
                        .init(title: "給料日", description: "給料日の月を設定できるようになりました。デフォルトでは翌月になっています。", symbolName: "yensign"),
                        .init(title: "パフォーマンス", description: "処理速度, 消費電力, Googleとの同期の安定性が向上しました。", symbolName: "swift"),
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
