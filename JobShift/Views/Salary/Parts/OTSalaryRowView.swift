import SwiftUI
import SwiftData

struct OTSalaryRowView: View {
    @Binding var includeCommuteWage: Bool
    var date: Date
    var dateMode: DateMode
    
    @Query private var otJobs: [OneTimeJob]
    @State private var targetOtJobs: [OneTimeJob] = []

    var body: some View {
        Section {
            HStack {
                Rectangle()
                    .fill(.secondary)
                    .frame(width: 4)
                    .cornerRadius(2)
                VStack {
                    NavigationLink(destination: {
                        OTSalaryDetailView(includeCommuteWage: $includeCommuteWage, date: date, dateMode: dateMode)
                    }, label: {
                        HStack {
                            Text("単発バイト")
                                .bold()
                            ConfirmChip(isConfirmed: true)
                            Spacer()
                            Text("\(targetOtJobs.count)出勤")
                                .foregroundColor(.secondary)
                                .font(.caption)
                        }
                    })
                    Spacer()
                    HStack {
                        Text("\(targetOtJobs.map { includeCommuteWage && $0.isCommuteWage ? $0.salary : max(0, $0.salary - $0.commuteWage) }.reduce(0, +))")
                            .font(.title.bold())
                            + Text(" 円")
                                .foregroundColor(.secondary)
                        Spacer()
                    }
                    .contentTransition(.numericText(countsDown: true))
                }
            }
            .frame(height: 72)
        }
        .listSectionSpacing(20)
        .onAppear {
            targetOtJobs = {
                if dateMode == .month {
                    return otJobs.filter { date.firstDayOfMonth <= $0.date && date.lastDayOfMonth > $0.date }
                } else {
                    let yearFirstDay = date.fixed(month: 1, day: 1, hour: 0, minute: 0, second: 0)
                    return otJobs.filter {  yearFirstDay <= $0.date && yearFirstDay.added(year: 1) > $0.date }
                }
            }()
        }
    }
}
