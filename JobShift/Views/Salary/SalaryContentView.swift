import SwiftUI
import Charts
import SwiftData

struct SalaryContentView: View {
    var date: Date
    var dateMode: DateMode
    @Binding var addSheetIsPresented: Bool
    @Binding var includeCommuteWage: Bool
    
    @State private var salaryData: [JobSalaryData] = []
    @Query(sort: \Job.order) private var jobs: [Job]
    var totalSalary: Int {
        return salaryData.map { salary in
            var jobSalary = salary.isConfirmed ? salary.confirmedSalary : salary.forecastSalary
            if salary.job.isCommuteWage && includeCommuteWage {
                jobSalary += salary.events.count * salary.job.commuteWage
            }
            return jobSalary
        }.reduce(0, +)
    }

    var body: some View {
        List {
            Chart(salaryData, id: \.self) { salary in
                let jobSalary = salary.isConfirmed ? salary.confirmedSalary : salary.forecastSalary + (salary.job.isCommuteWage && includeCommuteWage ? salary.events.count * salary.job.commuteWage : 0)
                SectorMark(
                    angle: .value("", jobSalary),
                    innerRadius: .ratio(0.9),
                    angularInset: 1.5
                )
                .cornerRadius(3)
                .foregroundStyle(salary.job.color.toColor())
            }
            .animation(.none)
            .frame(height: 260)
            .listRowBackground(Color.clear)
            .chartBackground { chartProxy in
                GeometryReader { geometry in
                    let frame = geometry[chartProxy.plotFrame!]
                    VStack {
                        Text("合計")
                            .foregroundStyle(.secondary)
                            .font(.caption)
                        Text("\(totalSalary)円")
                            .font(.title2.bold())
                    }
                    .contentTransition(.numericText(countsDown: true))
                    .position(x: frame.midX, y: frame.midY - 5)
                }
            }
            ForEach(salaryData) { salary in
                SalaryRowView(includeCommuteWage: $includeCommuteWage, salary: salary, date: date, dateMode: dateMode)
            }
        }
        .onAppear {
            salaryData = SalaryManager.shared.getSalaryData(date: date, jobs: jobs, dateMode: dateMode)
        }
        .onChange(of: addSheetIsPresented) {
            if !addSheetIsPresented {
                salaryData = SalaryManager.shared.getSalaryData(date: date, jobs: jobs, dateMode: dateMode)
            }
        }
    }
}
