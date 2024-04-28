import SwiftUI

struct ContentView: View {
    @State private var isShiftSheetPresented = false
    @State private var selectedTab: Tab = .shift
    @State private var isWelcomePresented = false
    private let AVAIABLE_OB_VERSION = "2"
    
    private func openShiftSheetForFirstTime() async {
        do {
            try await Task.sleep(millisecond: 260)
            if selectedTab == .shift {
                isShiftSheetPresented = true
            }
        } catch {
            print("ERROR: \(error.localizedDescription)")
        }
    }
    var body: some View {
        TabView(selection: $selectedTab) {
            ShiftView()
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
        .onChange(of: selectedTab) {
            isShiftSheetPresented = selectedTab == .shift
        }
        .onAppear {
            Task {
                isWelcomePresented = Storage.getLastSeenOnboardingVersion() != AVAIABLE_OB_VERSION
                if !isWelcomePresented {
                    await openShiftSheetForFirstTime()
                }
            }
        }
        .sheet(isPresented: $isShiftSheetPresented) {
            NavigationStack {
                Text("buttom sheet")
            }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .presentationDetents([.height(240), .large])
                .presentationCornerRadius(18)
                .presentationBackground(.bar)
                .presentationBackgroundInteraction(.enabled(upThrough: .large))
                .interactiveDismissDisabled()
                .bottomMaskForSheet()
        }
        .sheet(
            isPresented: $isWelcomePresented,
            onDismiss: {
                Storage.setLastSeenOnboardingVersion(AVAIABLE_OB_VERSION)
                Task { await openShiftSheetForFirstTime() }
            },
            content: {
                OBWelcomeView(
                    title: "ようこそサンプルアプリへ",
                    detailText: "これはOnBoardingKitのサンプルアプリです",
                    bulletedListItems: [
                        .init(title: "アプリの特徴1", description: "いろいろなことができます。", symbolName: "1.circle"),
                        .init(title: "アプリの特徴2", description: "いろいろなことができます。", symbolName: "2.circle"),
                        .init(title: "アプリの特徴3", description: "いろいろなことができます。", symbolName: "3.circle"),
                    ],
                    boldButtonItem: .init(title: "続ける", action: {
                        isWelcomePresented = false
                    })
                )
            }
        )
    }
}
