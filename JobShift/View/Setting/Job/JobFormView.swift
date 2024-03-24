import SwiftUI

enum JobFocusField {
    case dailyWage
    case commuteWage
}

struct JobFormView: View {
    @Bindable var viewModel: JobFormViewModel
    @FocusState private var focusState: JobFocusField?

    var body: some View {
        Section(header: Text("名前"), footer: Text("この名前を使用してGoogleカレンダーからイベントを取得します")) {
            TextField("名前", text: $viewModel.name)
        }
        Section {
            HStack {
                Text("カラー")
                Spacer()
                Menu {
                    Picker("", selection: $viewModel.color) {
                        ForEach(JobColor.allCases, id: \.self) { color in
                            Image(systemName: "circle.fill")
                                .tint(color.getColor())
                                .tag(color.japaneseColorName())
                        }
                    }
                    .pickerStyle(.palette)
                } label: {
                    HStack {
                        Text(viewModel.color.japaneseColorName())
                        Image(systemName: "circle.fill")
                            .font(.caption)
                            .tint(viewModel.color.getColor())
                    }
                }
            }
        }
        Section {
            Toggle("日給", isOn: $viewModel.isDailyWage.animation())
            if viewModel.isDailyWage {
                TextField("１日の給与(円)", text: $viewModel.dailyWageString)
                    .focused($focusState, equals: .dailyWage)
                    .keyboardType(.numberPad)
            }
        }
        .onChange(of: viewModel.isDailyWage) {
            if viewModel.isDailyWage {
                focusState = .dailyWage
            }
        }
        if !viewModel.isDailyWage {
            Section("基本時給(円)") {
                TextField("1200", text: $viewModel.hourlyWageString)
                    .keyboardType(.numberPad)
            }
        }
        Section {
            DatePicker("勤務開始日", selection: $viewModel.startDate, displayedComponents: .date)
                        .environment(\.locale, Locale(identifier: "ja_JP"))
                        .frame(height: 30)
            NavigationLink("昇給履歴", destination: WageHistoryView(viewModel: viewModel))
                .disabled(viewModel.firstWageError)
        }
        Section {
            Toggle("通勤手当", isOn: $viewModel.isCommuteWage.animation())
            if viewModel.isCommuteWage {
                TextField("往復料金(円)", text: $viewModel.commuteWageString)
                    .focused($focusState, equals: .commuteWage)
                    .keyboardType(.numberPad)
            }
        }
        .onChange(of: viewModel.isCommuteWage) {
            if viewModel.isCommuteWage {
                focusState = .commuteWage
            }
        }
        if !viewModel.isDailyWage {
            Section(footer: Text("有効な場合22:00〜翌5:00間を基本時給から25%加算して計算します。")) {
                Toggle("深夜手当", isOn: $viewModel.isNightWage)
            }
        }
        Section(footer: Text("""
        有効な場合 土, 日, 祝日を基本時給から35%加算して計算します。
        深夜手当が有効な場合22:00〜24:00は60%加算で計算し、24:00〜翌5:00は25%加算で計算します。なお翌日も休日の場合は22:00〜5:00間を60%加算で計算します。
        日給が有効の場合は日給に対して35%加算されます。
        """
        )) {
            Toggle("休日手当", isOn: $viewModel.isHolidayWage)
        }
        if !viewModel.isDailyWage {
            Section(header: Text("休憩設定")) {
                Toggle("休憩1", isOn: $viewModel.isBreak1.animation())
                if viewModel.isBreak1 {
                    BreakPicker(jobBreak: $viewModel.break1)
                }
                Toggle("休憩2", isOn: $viewModel.isBreak2.animation())
                if viewModel.isBreak2 {
                    BreakPicker(jobBreak: $viewModel.break2)
                }
            }
        }
        Section(footer: Text("""
        給料支払い日は支払日より1つ前の勤務期間で発生した給料が振り込まれる日です。
        例えば給料締日が10日で給料支払い日が25日の場合、2月16日〜3月15日の勤務期間で発生した給料が3月25日に振り込まれます。給料支払い日が祝日または休日の場合は前営業日に支払われるとします
        """)) {
            Toggle("給料支払い日を表示する", isOn: $viewModel.displayPaymentDay)
            HStack {
                Picker("給料締日", selection: $viewModel.salaryCutoffDay) {
                    ForEach(1..<32, id: \.self) { day in
                        Text("\(day)日")
                    }
                }
                
            }
            HStack {
                Picker("給料支払い日", selection: $viewModel.salaryPaymentDay) {
                    ForEach(1..<32, id: \.self) { day in
                        Text("\(day)日")
                    }
                }
            }
        }
    }
}
