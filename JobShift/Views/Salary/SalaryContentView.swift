import SwiftUI
import SwiftData

struct SalaryContentView: View {
    var date: Date
    @Binding var dateMode: DateMode
    @Binding var includeCommuteWage: Bool
    
    @State private var salaryData: [JobSalaryData] = []
    @Query(sort: \Job.order) private var jobs: [Job]

    var body: some View {
        List {
            ForEach(salaryData) { data in
                Section(header: Text("\(data.job.name)")) {
                    Text("\(data.events.map (\.salary).reduce(0, +))")
                    Text("\(data.events.map (\.minutes).reduce(0, +))")
                    Text("\(data.events.count)")
                }
            }
        }
        .onChange(of: dateMode) {
            salaryData = SalaryManager.shared.getSalaryData(date: date, jobs: jobs, dateMode: dateMode)
        }
        .onAppear {
            salaryData = SalaryManager.shared.getSalaryData(date: date, jobs: jobs, dateMode: dateMode)
        }
    }
}
