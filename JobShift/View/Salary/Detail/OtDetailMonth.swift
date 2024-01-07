import SwiftUI
import SwiftData

struct OtDetailMonth: View {
    @State var year: Int
    @State var month: Int
    @State private var targetOtJobs: [OneTimeJob] = []
    @Query private var otJobs: [OneTimeJob]
    
    var body: some View {
        List {
            Section {
                HStack {
                    Text("\(String(year))年 \(String(month))月")
                        .bold()
                    Spacer()
                    VStack {
                        HStack {
                            Spacer()
                            ConfirmChip(isConfirmed: true)
                            Text("\(targetOtJobs.reduce(0) { $0 + $1.salary })")
                                .font(.title2.bold())
                            + Text(" 円")
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            
            Section(header: Text("勤務履歴")) {
                ForEach(targetOtJobs) { job in
                    VStack {
                        HStack {
                            NavigationLink(destination: OTJobEditView(editOtJob: job)) {
                                Text("\(formattedDateString(from: job.date))")
                                    .font(.caption.bold())
                                    .foregroundColor(.secondary)
                            }
                        }

                        HStack {
                            Text("\(job.name)")
                                .font(.title3.bold())
                            Text("\(job.summary)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Spacer()
                            Text("\(job.salary)")
                                .font(.title3.bold())
                            + Text(" 円")
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
        }
        .navigationTitle("単発バイト")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            self.targetOtJobs = otJobs.filter { job in
                let jobDateComp = Calendar.current.dateComponents([.year, .month], from: job.date)
                return jobDateComp.year == year && jobDateComp.month == month
            }
            self.targetOtJobs.sort { $0.date > $1.date }
        }
    }
    private func formattedDateString(from date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "M月d日(E)"
        dateFormatter.locale = Locale(identifier: "ja_JP")
        let formattedString = dateFormatter.string(from: date)
        return formattedString
    }
}
