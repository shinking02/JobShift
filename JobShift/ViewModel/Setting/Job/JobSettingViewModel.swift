import Foundation
import SwiftUI

class JobSettingViewModel: ObservableObject {
    @Published var jobs: [Job] = []
    @Published var groupedOtJobs: [Int: [OneTimeJob]] = [:]
    private var oneTimeJobs: [OneTimeJob] = []
    private let dataSource = SwiftDataSource.shared
    
    init() {
        fetchFromSwiftData()
    }
    
    func fetchFromSwiftData() {
        self.jobs = dataSource.fetchJobs().sorted { $0.lastAccessedTime > $1.lastAccessedTime }
        self.oneTimeJobs = dataSource.fetchOTJobs()
        withAnimation {
            self.groupedOtJobs = Dictionary(grouping: self.oneTimeJobs) { (job: OneTimeJob) -> Int in
                let calendar = Calendar.current
                let year = calendar.component(.year, from: job.date)
                return year
            }
        }
    }
}
