import SwiftUI

struct DetailMonth: View {
    @State var year: Int
    @State var month: Int
    @State var targetJob: Job
    @State private var salary = Salary(isConfirmed: false, confirmedWage: 0, forcastWage: 0, commuteWage: 0, events: [], count: 1, totalMinutes: 0)
    @State private var lastSalary: Salary?
    var body: some View {
        List {
            Section {
                HStack {
                    Text("\(String(year))年 \(String(month))月")
                        .bold()
                    Spacer()
                    VStack {
                        HStack {
                            Spacer()
                            ConfirmChip(isConfirmed: true)
                            Text("\(salary.isConfirmed ? String.localizedStringWithFormat("%d", salary.confirmedWage) : " - ")")
                                .font(.title2.bold())
                            + Text(" 円")
                                .foregroundColor(.secondary)
                        }
                        HStack {
                            Spacer()
                            ConfirmChip(isConfirmed: false)
                            Text("\(salary.forcastWage)")
                                .font(.title2.bold())
                            + Text(" 円")
                                .foregroundColor(.secondary)
                        }
                    }
                }
                NavigationLink(destination: EditSalaryHistory(job: targetJob, year: year, month: month)) {
                    Text("給与実績を編集")
                        .foregroundColor(.blue)
                }
            }
            
            if salary.count > 0 {
                Section {
                    HStack {
                        VStack(alignment: .leading) {
                            let avgMinutes = salary.totalMinutes / salary.count
                            let lastAvgMinuutes = (lastSalary == nil || lastSalary?.count == 0) ? 0 : lastSalary!.totalMinutes / lastSalary!.count
                            let diff = avgMinutes - lastAvgMinuutes
                            let (color, image): (Color, String) = {
                                if diff > 0 {
                                    return (.green, "arrow.up")
                                }
                                if diff < 0 {
                                    return (.red, "arrow.down")
                                }
                                return (.secondary, "arrow.forward")
                            }()
                            Text("平均勤務時間")
                                .font(.caption.bold())
                                .foregroundColor(.secondary)
                            HStack {
                                Text(String(avgMinutes / 60))
                                    .font(.title2.bold())
                                + Text(" 時間 ")
                                    .font(.headline)
                                    .foregroundColor(.secondary)
                                + Text(String(avgMinutes % 60))
                                    .font(.title2.bold())
                                + Text(" 分")
                                    .font(.headline)
                                    .foregroundColor(.secondary)
                                Group {
                                    Text("\(String(abs(diff)))分")
                                        .foregroundColor(color)
                                        .font(.caption)
                                    Image(systemName: image)
                                        .frame(width: 3)
                                        .foregroundColor(color)
                                        .font(.caption2)
                                }.offset(y: 3)
                            }
                            
                        }
                        Spacer()
                        VStack(alignment: .leading) {
                            let lastCount = lastSalary == nil ? 0 : lastSalary!.count
                            let diff = salary.count - lastCount
                            let (color, image): (Color, String) = {
                                if diff > 0 {
                                    return (.green, "arrow.up")
                                }
                                if diff < 0 {
                                    return (.red, "arrow.down")
                                }
                                return (.secondary, "arrow.forward")
                            }()
                            Text("出勤回数")
                                .font(.caption.bold())
                                .foregroundColor(.secondary)
                            HStack {
                                Text(String(salary.count))
                                    .font(.title2.bold())
                                + Text(" 回")
                                    .font(.headline)
                                    .foregroundColor(.secondary)
                                Group {
                                    Text("\(String(abs(diff)))回")
                                        .foregroundColor(color)
                                        .font(.caption)
                                    Image(systemName: image)
                                        .frame(width: 3)
                                        .foregroundColor(color)
                                        .font(.caption2)
                                }.offset(y: 3)
                            }
                        }
                        Spacer()
                    }
                }
            }
            if !salary.events.isEmpty {
                Section(header: Text("勤務日")) {
                    ForEach(salary.events, id: \.self) { event in
                        let isAllday = event.start?.date?.date != nil
                        let start = event.start?.dateTime?.date ?? event.start?.date?.date ?? Date.distantPast
                        let end = event.end?.dateTime?.date ?? event.end?.date?.date ?? Date.distantFuture
                        HStack {
                            Text(formattedDateString(from: start))
                            Spacer()
                            if !isAllday {
                                VStack {
                                    Text(formattedTimeString(from: start))
                                    Text(formattedTimeString(from: end))
                                }
                                .font(.caption)
                                .foregroundColor(.secondary)
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle(targetJob.name)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            self.salary = SalaryManager.shared.getSalaries(jobs: [targetJob], otJobs: [], year: year, month: month)[0]
            let lastYear = month == 1 ? year - 1: year
            let lastMonth = month == 1 ? 12 : month - 1
            let lastSalaries = SalaryManager.shared.getSalaries(jobs: [targetJob], otJobs: [], year: lastYear, month: lastMonth)
            self.lastSalary = lastSalaries.isEmpty ? nil : lastSalaries[0]
        }
    }
    private func formattedDateString(from date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "M月d日(E)"
        dateFormatter.locale = Locale(identifier: "ja_JP")
        let formattedString = dateFormatter.string(from: date)
        return formattedString
    }
    private func formattedTimeString(from date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        let formattedString = dateFormatter.string(from: date)
        return formattedString
    }
}
