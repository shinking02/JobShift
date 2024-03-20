import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var viewModel = ContentViewModel()
    @State var shiftViewModel = ShiftViewModel()
    var body: some View {
        TabView(selection: $viewModel.selectedTab) {
            ShiftView()
                .tag(Tab.shift)
                .tabItem {
                    Label(Tab.shift.rawValue, systemImage: Tab.shift.symbol)
                }
                .toolbarBackground(.visible, for: .tabBar)
                .toolbarBackground(.bar, for: .tabBar)
                .environment(shiftViewModel)
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
            viewModel.onAppear()
        }
        .sheet(isPresented: $viewModel.showCalendarSheet) {
            ShiftSheetView()
            .environment(shiftViewModel)
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
