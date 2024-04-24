import SwiftUI

struct ContentView: View {
    @State private var isShiftSheetPresented = true
    @State private var selectedTab = Tab.shift
    
    private func openShiftSheetForFirstTime() async {
        do {
            try await Task.sleep(millisecond: 240)
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
    }
}
