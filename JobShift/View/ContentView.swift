import SwiftUI
import SwiftData

struct ContentView: View {
    var body: some View {
        TabView {
            ShiftView()
                .tabItem {
                    Image(systemName: "calendar")
                    Text("シフト")
                }
            SalaryView()
                .tabItem {
                    Image(systemName: "yensign")
                    Text("給与")
                }
            SettingView()
                .tabItem {
                    Image(systemName: "gear")
                    Text("設定")
                }
        }
    }
}
