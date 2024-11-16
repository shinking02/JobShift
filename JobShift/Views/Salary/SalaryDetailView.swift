import SwiftUI

struct SalaryDetailView: View {
    @Binding var includeCommuteWage: Bool
    @Bindable var job: Job
    @State var salary: JobSalaryData
    @State private var monthlySalary: [JobSalaryData] = []
    var date: Date
    var dateMode: DateMode
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack {
                        Text("\(salary.confirmedSalary + (includeCommuteWage && salary.job.isCommuteWage ? salary.events.count * salary.job.commuteWage : 0))円")
                            .bold()
                        Spacer()
                        ConfirmChip(isConfirmed: true)
                    }
                    HStack {
                        Text("\(salary.forecastSalary + (includeCommuteWage && salary.job.isCommuteWage ? salary.events.count * salary.job.commuteWage : 0))円")
                            .bold()
                        Spacer()
                        ConfirmChip(isConfirmed: false)
                    }
                    NavigationLink {
                        SalaryHistoryView(salaryHistoriesV2: $job.salaryHistoriesV2)
                            .environment(job)
                        EmptyView()
                    } label: {
                        Text("給与実績")
                    }
                }
                .contentTransition(.numericText(countsDown: true))
                
                Section {
                    HStack {
                        Text("出勤回数")
                        Spacer()
                        Text("\(salary.events.count)回")
                            .foregroundStyle(.secondary)
                    }
                    HStack {
                        let avgMinutes = salary.events.map(\.minutes).reduce(0, +) / max(salary.events.count, 0)
                        Text("平均勤務時間")
                        Spacer()
                        Text("\(avgMinutes / 60)時間 \(avgMinutes % 60)分")
                            .foregroundStyle(.secondary)
                    }
                }
                
                if dateMode == .month {
                    Section(header: Text("勤務日")) {
                        ForEach(salary.events) { event in
                            var detail: String {
                                let start = event.event.start.toString(.time)
                                let end = event.event.end.toString(.time)
                                if event.event.isAllDay {
                                    return "終日"
                                }
                                return "\(start)\n\(end)"
                            }
                            
                            HStack(alignment: .center) {
                                Text(event.event.start.toString(.weekday))
                                    .lineLimit(1)
                                Spacer()
                                Text(detail)
                                    .lineLimit(2)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .multilineTextAlignment(.center)
                            }
                        }
                    }
                } else {
                    Section {
                        ForEach(Array(monthlySalary.enumerated()), id: \.element) { index, mSalary in
                            HStack {
                                Group {
                                    Text("\(index + 1)月")
                                    ConfirmChip(isConfirmed: mSalary.isConfirmed)
                                }
                                Spacer()
                                Text("\((mSalary.isConfirmed ? mSalary.confirmedSalary : mSalary.forecastSalary) + (mSalary.job.isCommuteWage && includeCommuteWage ? mSalary.events.count * job.commuteWage : 0))円")
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }
            .onAppear {
                salary = SalaryManager.shared.getSalaryData(date: date, jobs: [job], dateMode: dateMode).first!
                if dateMode == .year {
                    monthlySalary.removeAll()
                    
                    let calendar = Calendar.current
                    var components = calendar.dateComponents([.year], from: date)
                    
                    for month in 1...12 {
                        components.month = month
                        components.day = 1
                        if let monthStartDate = calendar.date(from: components) {
                            if let monthlySalaryData = SalaryManager.shared.getSalaryData(date: monthStartDate, jobs: [job], dateMode: .month).first {
                                monthlySalary.append(monthlySalaryData)
                            }
                        }
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(
                        action: {
                            withAnimation {
                                includeCommuteWage.toggle()
                            }
                        },
                        label: {
                            Image(systemName: includeCommuteWage ? "tram.circle.fill" : "tram.circle")
                        }
                    )
                }
            }
            .navigationTitle(salary.job.name)
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
