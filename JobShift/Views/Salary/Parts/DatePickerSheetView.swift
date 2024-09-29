import SwiftUI

struct DatePickerSheetView: View {
    @Binding var dateMode: DateMode
    @Binding var selectedDate: Date
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedYear: Int
    @State private var selectedMonth: Int
    
    init(dateMode: Binding<DateMode>, selectedDate: Binding<Date>) {
        self._dateMode = dateMode
        self._selectedDate = selectedDate
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: selectedDate.wrappedValue)
        
        self._selectedYear = State(initialValue: components.year ?? calendar.component(.year, from: Date()))
        self._selectedMonth = State(initialValue: components.month ?? calendar.component(.month, from: Date()))
    }
    
    var body: some View {
        NavigationStack {
            Group {
                if dateMode == .month {
                    YearMonthPicker(selectedYear: $selectedYear, selectedMonth: $selectedMonth)
                } else {
                    Picker("", selection: $selectedYear) {
                        ForEach(1980..<2100, id: \.self) { year in
                            Text("\(String(year))年")
                        }
                    }
                    .pickerStyle(.wheel)
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("キャンセル") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("完了") {
                        updateSelectedDate()
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func updateSelectedDate() {
        var components = Calendar.current.dateComponents([.year, .month, .day], from: selectedDate)
        components.year = selectedYear
        components.month = selectedMonth
        selectedDate = Calendar.current.date(from: components) ?? selectedDate
    }
}
