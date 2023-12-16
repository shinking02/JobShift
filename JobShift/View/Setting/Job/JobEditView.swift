import Foundation
import SwiftUI
import SwiftData

struct JobEditView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) var dismiss
    @Query private var jobs: [Job]
    @Bindable var editJob: Job
    @State var newName = ""
    @State var nameErrorMessage = ""
    @State var showDeleteAlert = false
    
    var body: some View {
        List {
            Section(header: Text("名前"), footer: Text(nameErrorMessage).foregroundColor(.red)) {
                TextField("", text: $newName)
                    .onChange(of: newName) {
                        let isExistName = jobs.contains { $0.name == newName && $0.id != editJob.id }
                        if newName.isEmpty {
                            nameErrorMessage = "名前を入力してください"
                        } else if isExistName {
                            nameErrorMessage = "\(newName)は存在します"
                        } else {
                            nameErrorMessage = ""
                        }
                    }
            }
            Section {
                HStack {
                    Text("カラー")
                    Spacer()
                    Menu {
                        Picker("", selection: $editJob.color) {
                            ForEach(JobColor.allCases, id: \.self) { color in
                                Image(systemName: "circle.fill")
                                    .tint(color.getColor())
                                    .tag(color.japaneseColorName())
                            }
                        }
                        .pickerStyle(.palette)
                    } label: {
                        HStack {
                            Text(editJob.color.japaneseColorName())
                            Image(systemName: "circle.fill")
                                .font(.caption)
                                .tint(editJob.color.getColor())
                        }
                    }
                }
            }
            Section(header: Text("給与")) {
                Toggle("日給", isOn: $editJob.isDailyWage.animation())
                if editJob.isDailyWage {
                    HStack {
                        Text("1日の給料")
                        TextField("", value: $editJob.dailyWage, formatter: NumberFormatter())
                            .multilineTextAlignment(TextAlignment.trailing)
                            .keyboardType(.numberPad)
                        Text("円")
                            .foregroundColor(.secondary)
                    }
                } else {
                    HStack {
                        Text("基本時給")
                        TextField("", value: $editJob.wages[0].hourlyWage, formatter: NumberFormatter())
                            .multilineTextAlignment(TextAlignment.trailing)
                            .keyboardType(.numberPad)
                        Text("円")
                            .foregroundColor(.secondary)
                    }
                    Toggle("深夜手当", isOn: $editJob.isNightWage.animation())
                    if editJob.isNightWage {
                        DatePicker("開始", selection: $editJob.nightWageStartTime, displayedComponents: .hourAndMinute)
                            .frame(height: 30)
                        HStack {
                            Text("深夜時給")
                            TextField("", value: $editJob.wages[0].nightHourlyWage, formatter: NumberFormatter())
                                .multilineTextAlignment(TextAlignment.trailing)
                                .keyboardType(.numberPad)
                            Text("円")
                                .foregroundColor(.secondary)
                        }
                    }
                    Toggle("休日手当", isOn: $editJob.isHolidayWage.animation())
                    if editJob.isHolidayWage {
                        HStack {
                            Text("休日時給")
                            TextField("", value: $editJob.wages[0].holidayHourlyWage, formatter: NumberFormatter())
                                .multilineTextAlignment(TextAlignment.trailing)
                                .keyboardType(.numberPad)
                            Text("円")
                                .foregroundColor(.secondary)
                        }
                        if editJob.isNightWage {
                            HStack {
                                Text("休日深夜時給")
                                TextField("", value: $editJob.wages[0].holidayHourlyNightWage, formatter: NumberFormatter())
                                    .multilineTextAlignment(TextAlignment.trailing)
                                    .keyboardType(.numberPad)
                                Text("円")
                                    .foregroundColor(.secondary)
                            }
                            
                        }
                    }
                }
                NavigationLink(destination: WageHistoryView(job: editJob)) {
                    Text("昇給履歴")
                }
            }
            Section {
                Toggle("通勤手当", isOn: $editJob.isCommuteWage.animation())
                if editJob.isCommuteWage {
                    HStack {
                        Text("往復料金")
                        TextField("", value: $editJob.commuteWage, formatter: NumberFormatter())
                            .multilineTextAlignment(TextAlignment.trailing)
                            .keyboardType(.numberPad)
                        Text("円")
                            .foregroundColor(.secondary)
                    }
                }
            }
            if !editJob.isDailyWage {
                Section {
                    Toggle("休憩1", isOn: $editJob.isBreak1.animation())
                    if editJob.isBreak1 {
                        BreakPicker(jobBreak: $editJob.break1)
                    }
                    Toggle("休憩2", isOn: $editJob.isBreak2.animation())
                    if editJob.isBreak2 {
                        BreakPicker(jobBreak: $editJob.break2)
                    }
                }
            }
            Section {
                HStack {
                    Picker("給料締日", selection: $editJob.salaryCutoffDay) {
                        ForEach(1..<32, id: \.self) { day in
                            Text("\(day)日")
                        }
                    }
                    
                }
                HStack {
                    Picker("給料日", selection: $editJob.salaryPaymentDay) {
                        ForEach(1..<32, id: \.self) { day in
                            Text("\(day)日")
                        }
                    }
                }
            }
            Section {
                Button(action: {
                    self.showDeleteAlert = true
                }) {
                    HStack {
                        Spacer()
                        Text("バイトを削除")
                            .foregroundColor(.red)
                        Spacer()
                    }
                }
                .alert("\(newName.isEmpty ? editJob.name : newName)を削除しますか？", isPresented: $showDeleteAlert) {
                    Button("削除", role: .destructive) {
                        context.delete(editJob)
                        dismiss()
                    }
                    Button("キャンセル", role: .cancel) {}
                }
            }
        }
        .navigationTitle(editJob.name)
        .navigationBarTitleDisplayMode(.inline)
        .scrollDismissesKeyboard(.immediately)
        .onAppear {
            self.newName = editJob.name
        }
        .onDisappear {
            if nameErrorMessage.isEmpty {
                editJob.name = newName
                try? context.save()
            }
        }
    }
}
