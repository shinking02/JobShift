import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var viewModel = ContentViewModel()
    @State var shiftViewModel = ShiftViewModel()
    var body: some View {
        TabView(selection: $viewModel.selectedTab) {
            ForEach(Tab.allCases, id: \.rawValue) { tab in
                tab.view
                    .tag(tab)
                    .tabItem {
                        Label(tab.rawValue, systemImage: tab.symbol)
                    }
                    .toolbarBackground(.visible, for: .tabBar)
                    .toolbarBackground(.bar, for: .tabBar)
            }
        }
        .environment(shiftViewModel)
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
