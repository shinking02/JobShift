import SwiftUI

struct SalaryRowView: View {
    @State var entry: ChartEntry
    @Binding var includeCommuteWage: Bool
    @Binding var year: Int
    @Binding var month: Int

    var body: some View {
        Section {
            HStack {
                Rectangle()
                    .fill(entry.color)
                    .frame(width: 4)
                    .cornerRadius(2)
                VStack {
                    NavigationLink(destination: {
                        if entry.job != nil {
                            if month != 0 {
                                DetailMonthView(viewModel: DetailMonthViewModel(
                                    job: entry.job!,
                                    yearMonth: YearMonth(year: year, month: month),
                                    includeCommuteWage: includeCommuteWage
                                ))
                            } else {
                                DetailYearView(viewModel: DetailYearViewModel(
                                    job: entry.job!,
                                    year: year,
                                    includeCommuteWage: includeCommuteWage
                                ))
                            }
                        } else {
                            DetailSalaryOTJobView(viewModel: DetailSalaryOTJobViewModel(
                                year: year,
                                month: month,
                                includeCommuteWage: includeCommuteWage
                            ))
                        }
                    }, label: {
                        HStack {
                            Text(entry.label)
                                .bold()
                            ConfirmChip(isConfirmed: entry.isConfirm)
                            Spacer()
                            Text("\(entry.count)出勤")
                                .foregroundColor(.secondary)
                                .font(.caption)
                        }
                    })
                    Spacer()
                    HStack {
                        Text("\(entry.isConfirm ? entry.confirmSalary : entry.salary)")
                            .font(.title.bold())
                            + Text(" 円")
                                .foregroundColor(.secondary)
                        Spacer()
                        if !entry.isOtJob {
                            Text(String(entry.minutes / 60))
                                .font(.title2.bold())
                            + Text(" 時間 ")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            + Text(String(entry.minutes % 60))
                                .font(.title2.bold())
                            + Text(" 分")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .contentTransition(.numericText(countsDown: true))
                }
            }
            .frame(height: 80)
        }
        .listSectionSpacing(20)
    }
}
