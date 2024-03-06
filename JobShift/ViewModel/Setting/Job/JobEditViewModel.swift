import Foundation
import Observation

@Observable final class JobEditViewModel: JobFormViewModel {
    var showDeleteAlert = false
    @ObservationIgnored var job: Job
    private let swiftDataSouce = SwiftDataSource.shared
    
    required init(job: Job?) {
        self.job = job ?? Job()
        super.init(job: job)
    }
    
    func deleteButtonTapped() {
        showDeleteAlert = true
    }
    func jobDelete() {
        swiftDataSouce.removeJob(job)
    }
    func onDisappear() {
        job.name = name.isEmpty ? job.name : name
        job.color = color
        job.isDailyWage = isDailyWage
        job.isNightWage = isNightWage
        job.isHolidayWage = isHolidayWage
        job.wages = wages
        job.isCommuteWage = isCommuteWage && Int(commuteWageString) != nil
        job.commuteWage = Int(commuteWageString) ?? 0
        job.isBreak1 = isBreak1
        job.isBreak2 = isBreak2
        job.break1 = break1
        job.break2 = job.break2
        job.salaryCutoffDay = salaryCutoffDay
        job.salaryPaymentDay = salaryPaymentDay
        job.displayPaymentDay = displayPaymentDay
        job.startDate = startDate
        job.lastAccessedTime = Date()
    }
}
