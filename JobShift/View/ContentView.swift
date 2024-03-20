import SwiftUI
import SwiftData

struct ContentView: View {
    @EnvironmentObject var userState: UserState
    @EnvironmentObject var eventStore: EventStore
    var body: some View {
        TabView {
            ShiftView()
                .tabItem {
                    Image(systemName: "calendar")
                    Text("シフト")
                }
            SalaryMainView()
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
