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
        self.jobs = dataSource.fetchJobs()
        self.oneTimeJobs = dataSource.fetchOTJobs()
        self.groupedOtJobs = Dictionary(grouping: self.oneTimeJobs) { (job: OneTimeJob) -> Int in
            let calendar = Calendar.current
            let year = calendar.component(.year, from: job.date)
            return year
        }
    }
}
