import Observation
import Foundation

@Observable final class JobSettingViewModel {
    var jobs: [Job] = []
    var otJobs: [OneTimeJob] = []
    var groupedOtJobs: [Int: [OneTimeJob]] = [:]
    var expandedYears: Set<Int> = [Calendar.current.component(.year, from: Date())]
    var showingJobTypeDialog = false
    var showingAddJobView = false
    var showingAddOTJobView = false
    private let swiftDataSource = SwiftDataSource.shared
    
    func onAppear() {
        jobs = swiftDataSource.fetchJobs()
        otJobs = swiftDataSource.fetchOTJobs()
        updateGroupedOtJobs()
    }
    
    private func updateGroupedOtJobs() {
        groupedOtJobs = Dictionary(grouping: otJobs, by: { job in
            return Calendar.current.component(.year, from: job.date)
        })
    }
}

