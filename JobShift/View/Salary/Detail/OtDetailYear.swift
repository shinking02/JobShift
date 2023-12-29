import SwiftUI
import SwiftData
import Charts

struct OtDetailYear: View {
    @State var year: Int
    @State private var targetOtJobs: [OneTimeJob] = []
    @Query private var otJobs: [OneTimeJob]
    @State private var salaryAvg = 0
    @State private var showAvgLine = true
    @State private var chartData: [ChartData] = []
    
    var body: some View {
        List {
            Section {
                HStack {
                    Text("\(String(year))年")
                        .bold()
                    Spacer()
                    VStack {
                        HStack {
                            Spacer()
                            ConfirmChip(isConfirmed: true)
                            Text("\(targetOtJobs.reduce(0) { $0 + $1.salary })")
                                .font(.title2.bold())
                            + Text(" 円")
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            Section {
                VStack(alignment: .leading, spacing: 0) {
                    Text("月の平均")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                    Text("\(salaryAvg)")
                        .font(.title.bold())
                    + Text(" 円")
                        .bold()
                        .foregroundColor(.secondary)
                    Chart(chartData) { record in
                        BarMark(
                            x: .value("月", record.date, unit: .month),
                            y: .value("給与", record.salary),
                            width: 20
                        )
                        .opacity(showAvgLine ? 0.2 : 1)
                        .foregroundStyle(.primary)
                        if showAvgLine {
                            RuleMark(y: .value("平均", salaryAvg))
                                .foregroundStyle(.primary)
                                .lineStyle(StrokeStyle(lineWidth: 2))
                                .annotation(position: .top, alignment: .trailing) {
                                    Text(salaryAvg, format: .currency(code: "JPY"))
                                        .font(.subheadline)
                                        .foregroundColor(.blue)
                                }
                        }
                    }
                    .frame(height: 210)
                    .chartYAxis(content: {
                        AxisMarks(content: { value in
                            AxisGridLine()
                            AxisTick()
                            AxisValueLabel(content: {
                                if let intValue = value.as(Int.self) {
                                    Text("\(intValue / 1000)")
                                }
                            })
                        })
                    })
                    .chartXAxis {
                        AxisMarks(values: .stride(by: .month, count: 1)) { date in
                            AxisGridLine()
                            AxisTick()
                            AxisValueLabel(format: .dateTime.month(.defaultDigits), centered: true)
                        }
                    }
                    .chartYAxisLabel("千円")
                }
                Toggle(isOn: $showAvgLine.animation(), label: {
                    Text("平均を表示")
                })
            }
            Section(header: Text("勤務履歴")) {
                ForEach(targetOtJobs) { job in
                    VStack {
                        HStack {
                            NavigationLink(destination: OTJobEditView(editOtJob: job)) {
                                Text("\(formattedDateString(from: job.date))")
                                    .font(.caption.bold())
                                    .foregroundColor(.secondary)
                            }
                        }
                        HStack {
                            Text("\(job.name)")
                                .font(.title3.bold())
                            Spacer()
                            Text("\(job.salary)")
                                .font(.title3.bold())
                            + Text(" 円")
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
        }
        .navigationTitle("単発バイト")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            self.targetOtJobs = otJobs.filter { job in
                let jobDateComp = Calendar.current.dateComponents([.year], from: job.date)
                return jobDateComp.year == year
            }
            self.targetOtJobs.sort { $0.date > $1.date }
            let totalSalary = targetOtJobs.reduce(0) { $0 + $1.salary }
            self.salaryAvg = totalSalary / 12
            for month in 1...12 {
                let dateComp = DateComponents(year: year, month: month)
                let date = Calendar.current.date(from: dateComp)!
                let salary = targetOtJobs.filter { job in
                    let jobDateComp = Calendar.current.dateComponents([.year, .month], from: job.date)
                    return jobDateComp.year == year && jobDateComp.month == month
                }.reduce(0) { $0 + $1.salary }
                chartData.append(ChartData(date: date, salary: salary))
            }
        }
    }
    private func formattedDateString(from date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "M月d日(E)"
        dateFormatter.locale = Locale(identifier: "ja_JP")
        let formattedString = dateFormatter.string(from: date)
        return formattedString
    }
}

private struct ChartData: Identifiable {
    let id = UUID()
    var date: Date
    var salary: Int
}
