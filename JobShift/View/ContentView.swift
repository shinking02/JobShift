import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var viewModel = ContentViewModel()
//    @State private var shiftViewModel = ShiftViewModel()
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
//        .environmentObject(shiftViewModel)
        .sheet(isPresented: $viewModel.showCalendarSheet) {
//            ShiftSheetView()
//            .environmentObject(shiftViewModel)
            EmptyView()
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
