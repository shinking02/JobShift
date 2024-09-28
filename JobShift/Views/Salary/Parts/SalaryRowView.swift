import SwiftUI

struct SalaryRowView: View {
    @Binding var includeCommuteWage: Bool
    var salary: JobSalaryData
    var date: Date
    var dateMode: DateMode
    
    var body: some View {
        Section {
            HStack {
                Rectangle()
                    .fill(salary.job.color.toColor())
                    .frame(width: 4)
                    .cornerRadius(2)
                VStack {
                    NavigationLink(destination: {
                        SalaryDetailView(includeCommuteWage: $includeCommuteWage, job: salary.job, salary: salary, date: date, dateMode: dateMode)
                    }, label: {
                        HStack {
                            Text(salary.job.name)
                                .bold()
                            ConfirmChip(isConfirmed: salary.isConfirmed)
                            Spacer()
                            Text("\(salary.events.count)出勤")
                                .foregroundColor(.secondary)
                                .font(.caption)
                        }
                    })
                    Spacer()
                    HStack {
                        Text("\((salary.isConfirmed ? salary.confirmedSalary : salary.forecastSalary) + (salary.job.isCommuteWage && includeCommuteWage ? salary.events.count * salary.job.commuteWage : 0))")
                            .font(.title.bold())
                            + Text(" 円")
                                .foregroundColor(.secondary)
                        Spacer()
                        Text(String(salary.events.map(\.minutes).reduce(0, +) / 60))
                            .font(.title2.bold())
                        + Text(" 時間 ")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        + Text(String(salary.events.map(\.minutes).reduce(0, +) % 60))
                            .font(.title2.bold())
                        + Text(" 分")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .contentTransition(.numericText(countsDown: true))
                }
            }
            .frame(height: 72)
        }
        .listSectionSpacing(20)
    }
}
