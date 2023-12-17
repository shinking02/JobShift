import Foundation
import SwiftUI

struct WageHistoryView: View {
    @Environment(\.modelContext) private var context
    @Bindable var job: Job
    @State var showAddView = false
    var body: some View {
        List {
            ForEach(job.wages, id: \.self) { wage in
                if job.isDailyWage {
                    HStack {
                        Text("\(wage.dailyWage)円")
                        Spacer()
                        Text(getWageIntervalText(wage:wage))
                            .font(.caption)
                    }
                } else {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(getWageIntervalText(wage:wage))
                                .font(.caption)
                            Text("\(wage.hourlyWage)")
                                .font(.title2)
                                .bold()
                            + Text(" 円")
                                .bold()
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        VStack(alignment: .trailing) {
                            Text("深夜: \(job.isNightWage ? String(wage.nightHourlyWage) : "- ")円")
                            Text("休日: \(job.isHolidayWage ? String(wage.holidayHourlyWage) : "- ")円")
                            Text("休日深夜: \(job.isNightWage && job.isHolidayWage ? String(wage.holidayHourlyNightWage) : "- ")円")
                        }
                        .font(.caption)
                        .foregroundColor(.secondary)
                    }
                }
            }
            .onDelete(perform: job.wages.count < 2 ? nil : { index in
                withAnimation {
                    job.wages.remove(atOffsets: index)
                    let newWages = sortAndSetWageDate(wages: job.wages)
                    job.wages = newWages
                    try? context.save()
                }
            })
        }
        .navigationTitle("昇給履歴")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: {
                    self.showAddView = true
                }) {
                    Image(systemName: "plus")
                }
                .sheet(isPresented: $showAddView, content: {
                    WageAddView(job: job)
                })
            }
        }
    }
    private func getWageIntervalText(wage: Wage) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy年M月d日"
        if let start = wage.start, let end = wage.end {
            return "\(dateFormatter.string(from: start))~\(dateFormatter.string(from: end))"
        } else if let start = wage.start {
            return "\(dateFormatter.string(from: start))~現在"
        } else if let end = wage.end {
            return "~\(dateFormatter.string(from: end))"
        } else {
            return "~現在"
        }
    }
}
