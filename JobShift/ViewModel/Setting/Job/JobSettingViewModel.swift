import Observation
import Foundation

@Observable final class JobSettingViewModel {
    var jobs: [Job] = []
    var otJobs: [OneTimeJob] = []
    var groupedOtJobs: [Int: [OneTimeJob]] = [:]
    var showingJobTypeDialog = false
    var showingAddJobView = false
    var showingAddOTJobView = false
    private let swiftDataSource = SwiftDataSource.shared
    
    func onAppear() {
        jobs = swiftDataSource.fetchJobs()
        otJobs = swiftDataSource.fetchOTJobs()
        updateGroupedOtJobs()
    }
    
    func addJobButtonTapped() {
        showingAddJobView = true
    }
    
    func addOTJobButtonTapped() {
        showingAddOTJobView = true
    }
    
    func jobPlusButtonTapped() {
        showingJobTypeDialog = true
    }
    
    private func updateGroupedOtJobs() {
        groupedOtJobs = Dictionary(grouping: otJobs, by: { job in
            return Calendar.current.component(.year, from: job.date)
        })
    }
}

