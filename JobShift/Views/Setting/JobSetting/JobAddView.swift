import SwiftUI

struct JobAddView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @State private var job: Job = .init()
    @State private var paymentDayPickerPresented = false
    @State private var cutOffDayPickerPresented = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section(
                    header: Text("名前"),
                    footer: Text("この名前を使用してGoogleカレンダーからイベントを取得します。")
                ) {
                    TextField("名前", text: $job.name)
                }
                Section {
                    HStack {
                        Text("カラー")
                        Spacer()
                        Menu {
                            Picker("", selection: $job.color) {
                                ForEach(JobColor.allCases, id: \.self) { color in
                                    Image(systemName: "circle.fill")
                                        .tint(color.toColor())
                                }
                            }
                            .pickerStyle(.palette)
                        } label: {
                            Text(job.color.toString())
                            Image(systemName: "circle.fill")
                                .font(.caption)
                                .tint(job.color.toColor())
                        }
                    }
                }
                Section(
                    footer: Text("給与形態は追加後に変更することはできません。")
                ) {
                    DatePicker("入社日", selection: $job.wages.first!.start, displayedComponents: [.date])
                    Picker("給与形態", selection: $job.salaryType) {
                        ForEach(JobSalaryType.allCases, id: \.self) { salaryType in
                            Text(salaryType.toString())
                        }
                    }
                }
                Section {
                    NavigationLink {
                        WageHistoryView(wages: $job.wages)
                    } label: {
                        Text("基本給")
                    }
                    NavigationLink {
                        SalaryHistoryView(salary: $job.salary)
                    } label: {
                        Text("給与実績")
                    }
                }
                Section(
                    footer: Text(job.isCommuteWage ? "往復の金額を入力してください" : "")
                ) {
                    Toggle("通勤手当", isOn: $job.isCommuteWage)
                    if job.isCommuteWage {
                        NumberTextField(number: $job.commuteWage, label: "往復金額(円)")
                    }
                }
                if job.salaryType == .hourly {
                    Section(
                        footer: Text("有効な場合22:00〜翌5:00間を基本時給から25%加算して計算します。")
                    ) {
                        Toggle("深夜手当", isOn: $job.isNightWage)
                    }
                }
                Section(
                    footer: Text(
                        job.salaryType == .hourly
                        ?
                            """
                                   有効な場合 土, 日, 祝日を基本時給から35%加算して計算します。
                                   深夜手当が有効な場合22:00〜24:00は60%加算で計算し、24:00〜翌5:00は25%加算で計算します。翌日も休日の場合は22:00〜5:00間を60%加算で計算します。
                                   """
                        : "有効な場合 土, 日, 祝日を基本給から35%加算して計算します。"
                )) {
                    Toggle("休日手当", isOn: $job.isHolidayWage)
                }
                Section(
                    footer: Text("指定された日が存在しない場合、月末として計算されます。")
                ) {
                    Button {
                        withAnimation {
                            cutOffDayPickerPresented.toggle()
                        }
                    } label: {
                        HStack {
                            Text("給料締め日")
                            Spacer()
                            Text("\(job.salary.cutOffDay)日")
                                .foregroundColor(.secondary)
                        }
                    }
                    .tint(.primary)
                    if cutOffDayPickerPresented {
                        Picker("", selection: $job.salary.cutOffDay) {
                            ForEach(1...31, id: \.self) { day in
                                Text("\(day)日")
                            }
                        }
                        .pickerStyle(.wheel)
                    }
                    Picker("支払い月", selection: $job.salary.paymentType) {
                        ForEach(JobSalary.PaymentType.allCases, id: \.self) { paymentType in
                            Text(paymentType.toString())
                        }
                    }
                    Button {
                        withAnimation {
                            paymentDayPickerPresented.toggle()
                        }
                    } label: {
                        HStack {
                            Text("給料日")
                            Spacer()
                            Text("\(job.salary.paymentDay)日")
                                .foregroundColor(.secondary)
                        }
                    }
                    .tint(.primary)
                    if paymentDayPickerPresented {
                        Picker("", selection: $job.salary.paymentDay) {
                            ForEach(1...31, id: \.self) { day in
                                Text("\(day)日")
                            }
                        }
                        .pickerStyle(.wheel)
                    }
                }
                Section(
                    footer: Text("支払われる給料がある場合にカレンダーに表示されます。")
                ) {
                    Toggle("給料日を表示", isOn: $job.displayPaymentDay)
                }
            }
            .navigationTitle("新規バイト")
            .navigationBarTitleDisplayMode(.inline)
            .scrollDismissesKeyboard(.immediately)
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
                        context.insert(job)
                        dismiss()
                    } label: {
                        Text("追加")
                    }
                    .disabled(job.name.isEmpty)
                }
            }
        }
    }
}
