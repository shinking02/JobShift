import SwiftUI
import Charts

struct DetailYearView: View {
    @State var viewModel: DetailYearViewModel

    var body: some View {
        List {
            Section {
                HStack {
                    Text("\(String(viewModel.year))年")
                        .bold()
                    Spacer()
                    VStack {
                        HStack {
                            Spacer()
                            ConfirmChip(isConfirmed: true)
                            Text("\(viewModel.confirmSalary)")
                                .font(.title2.bold())
                            + Text(" 円")
                                .foregroundColor(.secondary)
                        }
                        HStack {
                            Spacer()
                            ConfirmChip(isConfirmed: false)
                            Text("\(viewModel.forcastSalary)")
                                .font(.title2.bold())
                            + Text(" 円")
                                .foregroundColor(.secondary)
                        }
                    }
                }
                NavigationLink(destination: EditSalaryHistoryView(viewModel: EditSalaryHistoryViewModel(job: viewModel.job))) {
                    Text("給与実績を編集")
                        .foregroundColor(.blue)
                }
            }
            Section {
                VStack(alignment: .leading, spacing: 0) {
                    Text("月の平均")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                    Text("\(viewModel.monthAvg)")
                        .font(.title.bold())
                    + Text(" 円")
                        .bold()
                        .foregroundColor(.secondary)
                    Chart(viewModel.yearChartDatas) { record in
                        BarMark(
                            x: .value("月", record.date, unit: .month),
                            y: .value("給与", record.salary),
                            width: 20
                        )
                        .opacity(0.2)
                        .foregroundStyle(viewModel.job.color.getColor())
                        RuleMark(y: .value("平均", viewModel.monthAvg))
                            .foregroundStyle(viewModel.job.color.getColor())
                            .lineStyle(StrokeStyle(lineWidth: 2))
                            .annotation(position: .top, alignment: .trailing) {
                                Text(viewModel.monthAvg, format: .currency(code: "JPY"))
                                    .font(.subheadline)
                                    .foregroundColor(viewModel.job.color.getColor())
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
            }
            Section {
                ForEach(viewModel.yearChartDatas) { record in
                    HStack {
                        Text("\(record.month)月")
                        ConfirmChip(isConfirmed: record.isConfirm)
                        Text("\(record.count)出勤")
                            .foregroundColor(.secondary)
                            .font(.caption)
                        Spacer()
                        Text("\(record.salary)円")
                    }
                }
            }
        }
        .navigationTitle(viewModel.job.name)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.onAppear()
        }
    }
}
