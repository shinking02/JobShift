import SwiftUI

struct SalaryAddSheetView: View {
    @Binding var salary: JobSalary
    @State var year = Date().year
    @State var month = Date().month
    @State private var salaryString = ""
    @Environment(\.dismiss) private var dismiss
    @State private var pickerIsPresented = false
    @State private var existError = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section(
                    footer: Text(existError ? "この月の給与実績は既に追加されています。" : "").foregroundStyle(.red)
                ) {
                    Button {
                        withAnimation { pickerIsPresented.toggle() }
                    } label: {
                        HStack {
                            Text("年月")
                            Spacer()
                            Text(String(year) + "年" + String(month) + "月")
                                .foregroundStyle(.secondary)
                        }
                    }
                    .tint(.primary)
                    if pickerIsPresented {
                        YearMonthPicker(selectedYear: $year, selectedMonth: $month)
                            .onChange(of: [month, year]) {
                                existError = salary.histories.contains { $0.year == year && $0.month == month }
                            }
                    }
                }
                Section(
                    header: Text("X月Y日に振り込まれた給料"),
                    footer: Text("X月Y日からX月Y日間の勤務分の給料です。交通費を含めてください。")
                ) {
                    TextField("金額", text: $salaryString)
                        .keyboardType(.numberPad)
                }
            }
            .navigationTitle("給与実績を追加")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                existError = salary.histories.contains { $0.year == year && $0.month == month }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Text("キャンセル")
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        salary.histories.append(
                            JobSalary.History(
                                salary: Int(salaryString) ?? 0,
                                year: year,
                                month: month
                            )
                        )
                        dismiss()
                    } label: {
                        Text("追加")
                    }
                    .disabled(salaryString.isEmpty || existError)
                }
            }
        }
    }
}
