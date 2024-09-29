import SwiftUI
import SwiftData

struct OTSalaryDetailView: View {
    @Binding var includeCommuteWage: Bool
    var date: Date
    var dateMode: DateMode
    
    @Query private var otJobs: [OneTimeJob]
    @State private var targetOtJobs: [OneTimeJob] = []
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack {
                        Text("\(targetOtJobs.map { includeCommuteWage && $0.isCommuteWage ? $0.salary : max(0, $0.salary - $0.commuteWage) }.reduce(0, +))円")
                            .bold()
                            .contentTransition(.numericText(countsDown: true))
                        Spacer()
                        ConfirmChip(isConfirmed: true)
                    }
                }
                Section {
                    ForEach(targetOtJobs) { job in
                        NavigationLink {
                            OTJobEditView(otJob: job)
                        } label: {
                            HStack {
                                Text(job.name)
                                Spacer()
                                Text(job.date.toString(.normal))
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }
            .navigationTitle("単発バイト")
            .navigationBarTitleDisplayMode(.inline)
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
}
