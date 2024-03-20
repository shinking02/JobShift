import SwiftUI
import Charts

struct DetailYear: View {
    @State var year: Int
    @State var targetJob: Job
    @State private var salary = Salary(isConfirmed: false, confirmedWage: 0, forcastWage: 0, commuteWage: 0, events: [], count: 1, totalMinutes: 0)
    @State private var chartData: [ChartData] = []
    @State private var salaryAvg = 0
    @State private var showAvgLine = true
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
                NavigationLink(destination: EditSalaryHistory(job: targetJob, year: year)) {
                    Text("給与実績を編集")
                        .foregroundColor(.blue)
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
                            y: .value("給与", record.salary.isConfirmed ? record.salary.confirmedWage : record.salary.forcastWage),
                            width: 20
                        )
                        .opacity(showAvgLine ? 0.2 : 1)
                        .foregroundStyle(record.salary.job?.color.getColor() ?? .secondary)
                        if showAvgLine {
                            RuleMark(y: .value("平均", salaryAvg))
                                .foregroundStyle(record.salary.job?.color.getColor() ?? .secondary)
                                .lineStyle(StrokeStyle(lineWidth: 2))
                                .annotation(position: .top, alignment: .trailing) {
                                    Text(salaryAvg, format: .currency(code: "JPY"))
                                        .font(.subheadline)
                                        .foregroundColor(record.salary.job?.color.getColor() ?? .secondary)
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
                                    Text("\(intValue / 10000)")
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
                    .chartYAxisLabel("万円")
                }
                Toggle(isOn: $showAvgLine.animation(), label: {
                    Text("平均を表示")
                })
            }
            Section {
                ForEach(chartData) { data in
                    HStack {
                        Text("\(Calendar.current.component(.month, from: data.date))月")
                        ConfirmChip(isConfirmed: data.salary.isConfirmed)
                        Text("\(data.salary.count)出勤")
                            .foregroundColor(.secondary)
                            .font(.caption)
                        Spacer()
                        Text("\(data.salary.isConfirmed ? data.salary.confirmedWage : data.salary.forcastWage)円")
                    }
                }
            }
        }
        .navigationTitle(targetJob.name)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            self.salary =  SalaryManager.shared.getSalaries(jobs: [targetJob], otJobs: [], year: year, month: nil)[0]
            self.salaryAvg = (salary.isConfirmed ? salary.confirmedWage : salary.forcastWage) / 12
            for month in 1...12 {
                let salary = SalaryManager.shared.getSalaries(jobs: [targetJob], otJobs: [], year: year, month: month)[0]
                let date = DateComponents(calendar: .current, year: year, month: month).date!
                let chartData = ChartData(salary: salary, date: date)
                self.chartData.append(chartData)
            }
        }
    }
}

private struct ChartData: Identifiable {
    let id = UUID()
    var salary: Salary
    var date: Date
}
