import Foundation
import SwiftUI
import SwiftData

struct JobAddView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var eventStore: EventStore
    @EnvironmentObject var userState: UserState
    @Query private var jobs: [Job]
    @Bindable var newJob = Job()
    @State var showAlert = false
    @State var alertMessage = ""
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("名前"),footer: Text("この名前を使用してGoogleカレンダーからイベントを取得します。")) {
                    TextField("", text: $newJob.name)
                }
                Section {
                    HStack {
                        Text("カラー")
                        Spacer()
                        Menu {
                            Picker("", selection: $newJob.color) {
                                ForEach(JobColor.allCases, id: \.self) { color in
                                    Image(systemName: "circle.fill")
                                        .tint(color.getColor())
                                        .tag(color.japaneseColorName())
                                }
                            }
                            .pickerStyle(.palette)
                        } label: {
                            HStack {
                                Text(newJob.color.japaneseColorName())
                                Image(systemName: "circle.fill")
                                    .font(.caption)
                                    .tint(newJob.color.getColor())
                            }
                        }
                    }
                }
                Section(header: Text("給与")) {
                    Toggle("日給", isOn: $newJob.isDailyWage.animation())
                    if newJob.isDailyWage {
                        HStack {
                            Text("1日の給料")
                            TextField("", value: $newJob.wages[0].dailyWage, formatter: NumberFormatter())
                                .multilineTextAlignment(TextAlignment.trailing)
                                .keyboardType(.numberPad)
                            Text("円")
                                .foregroundColor(.secondary)
                        }
                    } else {
                        HStack {
                            Text("基本時給")
                            TextField("", value: $newJob.wages[0].hourlyWage, formatter: NumberFormatter())
                                .multilineTextAlignment(TextAlignment.trailing)
                                .keyboardType(.numberPad)
                            Text("円")
                                .foregroundColor(.secondary)
                        }
                        Toggle("深夜手当", isOn: $newJob.isNightWage.animation())
                        if newJob.isNightWage {
                            DatePicker("開始", selection: $newJob.nightWageStartTime, displayedComponents: .hourAndMinute)
                                .frame(height: 30)
                            HStack {
                                Text("深夜時給")
                                TextField("", value: $newJob.wages[0].nightHourlyWage, formatter: NumberFormatter())
                                    .multilineTextAlignment(TextAlignment.trailing)
                                    .keyboardType(.numberPad)
                                Text("円")
                                    .foregroundColor(.secondary)
                            }
                        }
                        Toggle("休日手当", isOn: $newJob.isHolidayWage.animation())
                        if newJob.isHolidayWage {
                            HStack {
                                Text("休日時給")
                                TextField("", value: $newJob.wages[0].holidayHourlyWage, formatter: NumberFormatter())
                                    .multilineTextAlignment(TextAlignment.trailing)
                                    .keyboardType(.numberPad)
                                Text("円")
                                    .foregroundColor(.secondary)
                            }
                            if newJob.isNightWage {
                                HStack {
                                    Text("休日深夜時給")
                                    TextField("", value: $newJob.wages[0].holidayHourlyNightWage, formatter: NumberFormatter())
                                        .multilineTextAlignment(TextAlignment.trailing)
                                        .keyboardType(.numberPad)
                                    Text("円")
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                    NavigationLink(destination: WageHistoryView(job: newJob)) {
                        Text("昇給履歴")
                    }
                }
                Section {
                    Toggle("通勤手当", isOn: $newJob.isCommuteWage.animation())
                    if newJob.isCommuteWage {
                        HStack {
                            Text("往復料金")
                            TextField("", value: $newJob.commuteWage, formatter: NumberFormatter())
                                .multilineTextAlignment(TextAlignment.trailing)
                                .keyboardType(.numberPad)
                            Text("円") 
                                .foregroundColor(.secondary)
                        }
                    }
                }
                if !newJob.isDailyWage {
                    Section {
                        Toggle("休憩1", isOn: $newJob.isBreak1.animation())
                        if newJob.isBreak1 {
                            BreakPicker(jobBreak: $newJob.break1)
                        }
                        Toggle("休憩2", isOn: $newJob.isBreak2.animation())
                        if newJob.isBreak2 {
                            BreakPicker(jobBreak: $newJob.break2)
                        }
                    }
                }
                Section {
                    HStack {
                        Picker("給料締日", selection: $newJob.salaryCutoffDay) {
                            ForEach(1..<32, id: \.self) { day in
                                Text("\(day)日")
                            }
                        }
                        
                    }
                    HStack {
                        Picker("給料日", selection: $newJob.salaryPaymentDay) {
                            ForEach(1..<32, id: \.self) { day in
                                Text("\(day)日")
                            }
                        }
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("キャンセル") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("追加") {
                        let isExistName = jobs.contains { $0.name == newJob.name }
                        if newJob.name.isEmpty {
                            self.alertMessage = "バイト名を入力してください"
                            self.showAlert = true
                        } else if isExistName {
                            self.alertMessage = "\(newJob.name)は存在します"
                            self.showAlert = true
                        } else {
                            eventStore.updateCalendarForStore(calendars: userState.selectedCalendars) { success in }
                            context.insert(newJob)
                            dismiss()
                        }
                    }
                    .alert("エラー", isPresented: $showAlert) {
                        Button("OK") {
                            self.showAlert = false
                        }
                    } message: {
                        Text(alertMessage)
                    }
                }
            }
            .navigationTitle("新規バイト")
            .navigationBarTitleDisplayMode(.inline)
            .scrollDismissesKeyboard(.immediately)
        }
    }
}
