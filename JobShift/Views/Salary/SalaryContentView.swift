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
    @Query private var otJobs: [OneTimeJob]
    private var totalSalary: Int {
        return salaryData.map { salary in
            var jobSalary = salary.isConfirmed ? salary.confirmedSalary : salary.forecastSalary
            if salary.job.isCommuteWage && includeCommuteWage {
                jobSalary += salary.events.count * salary.job.commuteWage
            }
            return jobSalary
        }.reduce(0, +)
    }
    private var otJobTotalSalary: Int {
        let targetOtJobs = {
            if dateMode == .month {
                return otJobs.filter { date.firstDayOfMonth <= $0.date && date.lastDayOfMonth > $0.date }
            } else {
                let yearFirstDay = date.fixed(month: 1, day: 1, hour: 0, minute: 0, second: 0)
                return otJobs.filter {  yearFirstDay <= $0.date && yearFirstDay.added(year: 1) > $0.date }
            }
        }()
        return targetOtJobs.map { includeCommuteWage && $0.isCommuteWage ? $0.salary : max(0, $0.salary - $0.commuteWage) }.reduce(0, +)
    }

    var body: some View {
        List {
            Chart {
                ForEach(salaryData, id: \.self) { salary in
                    let jobSalary = salary.isConfirmed ? salary.confirmedSalary : salary.forecastSalary + (salary.job.isCommuteWage && includeCommuteWage ? salary.events.count * salary.job.commuteWage : 0)
                    SectorMark(
                        angle: .value("", jobSalary),
                        innerRadius: .ratio(0.9),
                        angularInset: 1.5
                    )
                    .cornerRadius(3)
                    .foregroundStyle(salary.job.color.toColor())
                }
                SectorMark(
                    angle: .value("", otJobTotalSalary),
                    innerRadius: .ratio(0.9),
                    angularInset: 1.5
                )
                .cornerRadius(3)
                .foregroundStyle(Color.secondary)
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
                        Text("\(totalSalary + otJobTotalSalary)円")
                            .font(.title2.bold())
                    }
                    .contentTransition(.numericText(countsDown: true))
                    .position(x: frame.midX, y: frame.midY - 5)
                }
            }
            ForEach(salaryData) { salary in
                SalaryRowView(includeCommuteWage: $includeCommuteWage, salary: salary, date: date, dateMode: dateMode)
            }
            OTSalaryRowView(includeCommuteWage: $includeCommuteWage, date: date, dateMode: dateMode)
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
