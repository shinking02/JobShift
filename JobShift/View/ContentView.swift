//
//  ContentView.swift
//  JobShift
//
//  Created by 川上真 on 2023/12/10.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @EnvironmentObject var userState: UserState
    
    var body: some View {
        if (userState.isLoggedIn) {
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
        } else {
            LaunchScreen()
        }
    }

    
}
