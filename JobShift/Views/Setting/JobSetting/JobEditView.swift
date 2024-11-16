import SwiftUI

struct JobEditView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @Bindable var job: Job
    @State private var paymentDayPickerPresented = false
    @State private var cutOffDayPickerPresented = false
    @State private var showDeleteAlert = false
    
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
                    footer: Text("給与形態は変更できません。")
                ) {
                    DatePicker("入社日", selection: $job.jobWages.first!.start, displayedComponents: [.date])
                    Text("給与形態")
                        .badge(job.salaryType.toString())
                }
                Section {
                    NavigationLink {
                        WageHistoryView(wages: $job.jobWages)
                    } label: {
                        Text("基本給")
                    }
                    NavigationLink {
                        SalaryHistoryView(salaryHistoriesV2: $job.salaryHistoriesV2)
                            .environment(job)
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
                if job.salaryType == .hourly {
                    Section {
                        Toggle("休憩1", isOn: $job.breaks[0].isActive)
                        if job.breaks[0].isActive {
                            BreakPicker(jobBreak: $job.breaks[0])
                        }
                        Toggle("休憩2", isOn: $job.breaks[1].isActive)
                        if job.breaks[1].isActive {
                            BreakPicker(jobBreak: $job.breaks[1])
                        }
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
                            Text("\(job.salaryCutOffDay)日")
                                .foregroundColor(.secondary)
                        }
                    }
                    .tint(.primary)
                    if cutOffDayPickerPresented {
                        Picker("", selection: $job.salaryCutOffDay) {
                            ForEach(1...31, id: \.self) { day in
                                Text("\(day)日")
                            }
                        }
                        .pickerStyle(.wheel)
                        .onChange(of: job.salaryPaymentType) {
                            updateSalaryDay()
                        }
                    }
                    Picker("支払い月", selection: $job.salaryPaymentType) {
                        ForEach(SalaryPaymentType.allCases, id: \.self) { paymentType in
                            Text(paymentType.toString())
                        }
                    }
                    .onChange(of: job.salaryPaymentType) {
                        updateSalaryDay()
                    }
                    Button {
                        withAnimation {
                            paymentDayPickerPresented.toggle()
                        }
                    } label: {
                        HStack {
                            Text("給料日")
                            Spacer()
                            Text("\(job.salaryPaymentDay)日")
                                .foregroundColor(.secondary)
                        }
                    }
                    .tint(.primary)
                    if paymentDayPickerPresented {
                        Picker("", selection: $job.salaryPaymentDay) {
                            ForEach((job.salaryPaymentType == .nextMonth ? 1 : job.salaryCutOffDay)...31, id: \.self) { day in
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
                Section {
                    Button {
                        showDeleteAlert = true
                    } label: {
                        Text("削除")
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                    .tint(.red)
                    .alert("確認", isPresented: $showDeleteAlert) {
                        Button("キャンセル", role: .cancel) {}
                        Button("削除", role: .destructive) {
                            context.delete(job)
                            dismiss()
                        }
                    } message: {
                        Text("\(job.name)を削除しますか？")
                    }
                }
            }
            .navigationTitle(job.name)
            .scrollDismissesKeyboard(.immediately)
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    private func updateSalaryDay() {
        if job.salaryPaymentType == .sameMonth && job.salaryCutOffDay > job.salaryPaymentDay {
            job.salaryPaymentDay = job.salaryCutOffDay
        }
    }
}
