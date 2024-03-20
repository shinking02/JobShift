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
                            return newWage.start
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
                            return Calendar.current.isDate(wage.start, inSameDayAs: newWage.start)
                        }
                        if existSameDate {
                            self.showAlert = true
                        } else {
                            let calendar = Calendar.current
                            newWage.start = calendar.date(bySettingHour: 0, minute: 0, second: 0, of: newWage.start)!
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
                        Text("\(getDateString(date: newWage.start))の昇給履歴が存在します")
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
    let calendar = Calendar.current
    var result = wages
    result.sort { $0.start < $1.start }
    for i in 0..<result.count {
        if i < result.count - 1 {
            let nextStart = result[i + 1].start
            let oneDayBefore = calendar.date(byAdding: .day, value: -1, to: nextStart)
            let endOfDay = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: oneDayBefore!)
            result[i].end = endOfDay!
        } else {
            result[i].end = Date.distantFuture
        }
    }
    result[0].start = Date.distantPast
    return result
}

