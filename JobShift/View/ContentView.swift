import SwiftUI
import SwiftData

struct ContentView: View {
    @EnvironmentObject var userState: UserState
    
    var body: some View {
        TabView {
            Text("シフト")
                .tabItem {
                    Image(systemName: "calendar")
                    Text("シフト")
                }
            Text("給与")
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
