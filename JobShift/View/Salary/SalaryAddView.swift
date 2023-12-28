import SwiftUI
import SwiftData

struct SalaryAddView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @State var year: Int
    @State var month: Int
    @State var selectedJob: Job
    @Query private var jobs: [Job]
    @State private var salary: Int = 0
    @State private var showAlert = false
    @State private var pickerIsPresented = false
    
    var body: some View {
        NavigationView {
            List {
                Section(footer: Text("交通費を含めてください")) {
                    Picker("バイト", selection: $selectedJob) {
                        ForEach(jobs, id: \.self) { job in
                            HStack {
                                Text(job.name).tag(job.name)
                                Spacer()
                                Text("")
                            }
                        }
                    }
                    Button {
                        withAnimation {
                            pickerIsPresented.toggle()
                        }
                    } label: {
                        HStack {
                            Text("年月")
                                .foregroundColor(.primary)
                            Spacer()
                            Text("\(String(year))年 \(String(month))月")
                                .foregroundColor(pickerIsPresented ? .blue : .secondary)
                            Image(systemName: "chevron.down")
                                .rotationEffect(.degrees(pickerIsPresented ? 0 : -90))
                                .foregroundColor(pickerIsPresented ? .blue : .secondary)
                        }
                    }
                    if pickerIsPresented {
                        CustomDatePicker(selectedYear: $year, selectedMonth: $month, showMonth: true)
                    }
                    HStack {
                        Text("給与")
                        TextField("", value: $salary, formatter: NumberFormatter())
                            .multilineTextAlignment(TextAlignment.trailing)
                            .keyboardType(.numberPad)
                        Text("円")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("給与実績の追加")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("キャンセル") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("追加") {
                        let existSalary = selectedJob.salaryHistories.first { $0.month == month && $0.year == year }
                        if existSalary != nil {
                            self.showAlert = true
                            return
                        }
                        selectedJob.salaryHistories.append(SalaryHistory(salary: salary, year: year, month: month))
                        try? context.save()
                        dismiss()
                    }
                    .alert("エラー", isPresented: $showAlert) {
                        Button("OK") {
                            self.showAlert = false
                        }
                    } message: {
                        Text("\(String(year))年\(month)月の給与実績が存在します")
                    }
                }
            }
        }
    }
}
