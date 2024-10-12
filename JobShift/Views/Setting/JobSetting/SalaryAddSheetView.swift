import SwiftUI

struct SalaryAddSheetView: View {
    @Binding var salary: JobSalary
    @State var year = Date().year
    @State var month = Date().month
    @State private var salaryString = ""
    @Environment(Job.self) private var job
    @Environment(\.dismiss) private var dismiss
    @State private var pickerIsPresented = false
    @State private var errorMessage = ""
    
    var body: some View {
        let paymentDay = job.getPaymentDay(year: year, month: month)
        let workInterval = job.getWorkInterval(year: year, month: month)
        
        NavigationStack {
            Form {
                Section(
                    footer: Text(errorMessage).foregroundStyle(.red)
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
                                if job.jobWages.sorted(by: { $0.start < $1.start }).first!.start > workInterval.end {
                                    errorMessage = "入社日より前の給料は設定できません。"
                                } else if salary.histories.contains(where: { $0.year == year && $0.month == month }) {
                                    errorMessage = "この月の給与実績は既に追加されています。"
                                } else {
                                    errorMessage = ""
                                }
                            }
                    }
                }
                Section(
                    header: Text("\(paymentDay.month)月\(paymentDay.day)日に振り込まれた給料"),
                    footer: Text("\(workInterval.start.month)月\(workInterval.start.day)日から\(workInterval.end.month)月\(workInterval.end.day)日間の勤務分の給料です。交通費を含めてください。")
                ) {
                    TextField("金額", text: $salaryString)
                        .keyboardType(.numberPad)
                }
            }
            .navigationTitle("給与実績を追加")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                if job.jobWages.sorted(by: { $0.start < $1.start }).first!.start > workInterval.end {
                    errorMessage = "入社日より前の給料は設定できません。"
                } else if job.salary.histories.contains(where: { $0.year == year && $0.month == month }) {
                    errorMessage = "この月の給与実績は既に追加されています。"
                } else {
                    errorMessage = ""
                }
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
                            JobSalaryHistory(
                                salary: Int(salaryString) ?? 0,
                                year: year,
                                month: month
                            )
                        )
                        dismiss()
                    } label: {
                        Text("追加")
                    }
                    .disabled(salaryString.isEmpty || !errorMessage.isEmpty)
                }
            }
        }
    }
}
