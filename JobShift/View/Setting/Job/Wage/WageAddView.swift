import Foundation
import SwiftUI

struct WageAddView : View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) var dismiss
    @Bindable var job: Job
    @State private var newWage: Wage = Wage(start: Date())
    @State var showAlert = false
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    DatePicker("昇給日", selection: Binding(
                        get: {
                            return newWage.start ?? Date()
                        },
                        set: { newValue in
                            newWage.start = newValue
                        }
                    ), displayedComponents: .date)
                        .frame(height: 30)
                        .environment(\.locale, Locale(identifier: "ja_JP"))
                }
                Section {
                    if job.isDailyWage {
                        HStack {
                            Text("1日の給料")
                            TextField("", value: $newWage.dailyWage, formatter: NumberFormatter())
                                .multilineTextAlignment(TextAlignment.trailing)
                                .keyboardType(.numberPad)
                            Text("円")
                                .foregroundColor(.secondary)
                        }
                    } else {
                        HStack {
                            Text("基本時給")
                            TextField("", value: $newWage.hourlyWage, formatter: NumberFormatter())
                                .multilineTextAlignment(TextAlignment.trailing)
                                .keyboardType(.numberPad)
                            Text("円")
                                .foregroundColor(.secondary)
                        }
                        if job.isNightWage {
                            HStack {
                                Text("深夜時給")
                                TextField("", value: $newWage.nightHourlyWage, formatter: NumberFormatter())
                                    .multilineTextAlignment(TextAlignment.trailing)
                                    .keyboardType(.numberPad)
                                Text("円")
                                    .foregroundColor(.secondary)
                            }
                        }
                        if job.isHolidayWage {
                            HStack {
                                Text("休日時給")
                                TextField("", value: $newWage.holidayHourlyWage, formatter: NumberFormatter())
                                    .multilineTextAlignment(TextAlignment.trailing)
                                    .keyboardType(.numberPad)
                                Text("円")
                                    .foregroundColor(.secondary)
                            }
                        }
                        if job.isNightWage && job.isHolidayWage {
                            HStack {
                                Text("休日深夜時給")
                                TextField("", value: $newWage.holidayHourlyNightWage, formatter: NumberFormatter())
                                    .multilineTextAlignment(TextAlignment.trailing)
                                    .keyboardType(.numberPad)
                                Text("円")
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
            }
            .navigationTitle("昇給履歴の追加")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("キャンセル") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("追加") {
                        let existSameDate = job.wages.contains { wage in
                            if let wageStartDate = wage.start, let targetStartDate = newWage.start {
                                return Calendar.current.isDate(wageStartDate, inSameDayAs: targetStartDate)
                            }
                            return false
                        }
                        if existSameDate {
                            self.showAlert = true
                        } else {
                            var wages = job.wages
                            wages.append(newWage)
                            job.wages = sortAndSetWageDate(wages: wages)
                            try? context.save()
                            dismiss()
                        }
                    }
                    .alert("エラー", isPresented: $showAlert) {
                        Button("OK") {
                            self.showAlert = false
                        }
                    } message: {
                        Text("\(getDateString(date: newWage.start!))の昇給履歴が存在します")
                    }
                }
            }
        }
    }
    private func getDateString(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy年M月d日"
        return dateFormatter.string(from: date)
    }
}

func sortAndSetWageDate(wages: [Wage]) -> [Wage] {
    var result = wages
    result.sort { (wage1, wage2) -> Bool in
        if let start1 = wage1.start, let start2 = wage2.start {
            return start1 < start2
        } else {
            return wage1.start == nil
        }
    }
    for i in 0..<result.count {
        if i < result.count - 1 {
            if let nextStart = result[i + 1].start {
                let oneDayBefore = Calendar.current.date(byAdding: .day, value: -1, to: nextStart)
                result[i].end = oneDayBefore
            }
        } else {
            result[i].end = nil
        }
    }
    result[0].start = nil
    return result
}

