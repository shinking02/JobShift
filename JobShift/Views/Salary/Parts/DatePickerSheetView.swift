import SwiftUI

struct DatePickerSheetView: View {
    @Binding var selectedTab: NavigationTab
    @Binding var selectedYearMonth: YearMonth
    @Binding var selectedYear: Year
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            Group {
                if selectedTab == .month {
                    YearMonthPicker(selectedYear: $selectedYearMonth.year, selectedMonth: $selectedYearMonth.month)
                } else {
                    Picker("", selection: $selectedYear.year) {
                        ForEach(1_980..<2_100, id: \.self) { year in
                            Text("\(String(year))年")
                        }
                    }
                    .pickerStyle(.wheel)
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("完了") {
                        dismiss()
                    }
                }
            }
        }
    }
}
