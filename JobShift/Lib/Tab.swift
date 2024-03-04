import SwiftUI

enum Tab: String, CaseIterable {
    case shift = "シフト"
    case salary = "給与"
    case setting = "設置"
    
    var symbol: String {
        switch self {
        case .shift:
            "calendar"
        case .salary:
            "yensign"
        case .setting:
            "gear"
        }
    }
    
    @ViewBuilder
    var view: some View {
        switch self {
        case .shift:
            ShiftView()
            EmptyView()
        case .salary:
            SalaryView()
        case .setting:
            SettingView()
        }
    }
}
