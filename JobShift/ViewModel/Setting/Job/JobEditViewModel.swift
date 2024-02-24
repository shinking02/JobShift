import Foundation

class JobEditViewModel: JobBaseViewModel {
    private var job: Job
    init(job: Job) {
        self.job = job
        super.init()
        self.name = job.name
        self.color = job.color
        self.isDailyWage = job.isDailyWage
        self.isNightWage = job.isNightWage
        self.isHolidayWage = job.isHolidayWage
        self.isCommuteWage = job.isCommuteWage
        self.dailyWageString = job.isDailyWage ? String(job.wages[0].dailyWage) : ""
        self.hourlyWageString = !job.isDailyWage ? String(job.wages[0].hourlyWage) : ""
        self.startDate = job.startDate
        self.wages = job.wages
        self.commuteWageString = job.isCommuteWage ? String(job.commuteWage) : ""
        self.isBreak1 = job.isBreak1
        self.isBreak2 = job.isBreak2
        self.break1 = job.break1
        self.break2 = job.break2
        self.salaryCutoffDay = job.salaryCutoffDay
        self.salaryPaymentDay = job.salaryPaymentDay
        self.displayPaymentDay = job.displayPaymentDay
        self.firstWageError = false
        self.validationError = false
    }
    
    func delete() {
        dataSource.removeJob(job)
    }
    
    func trySave() {
        print("try")
        if validationError {
            return
        }
        job.name = name
        job.color = color
        job.isDailyWage = isDailyWage
        job.isNightWage = isNightWage
        job.isHolidayWage = isHolidayWage
        job.isCommuteWage = isCommuteWage
        job.wages = wages
        job.startDate = startDate
        job.commuteWage = Int(commuteWageString) ?? 0
        job.isBreak1 = isBreak1
        job.isBreak2 = isBreak2
        job.break1 = break1
        job.break2 = break2
        job.salaryCutoffDay = salaryCutoffDay
        job.salaryPaymentDay = salaryPaymentDay
        job.displayPaymentDay = displayPaymentDay
        job.lastAccessedTime = Date()
        print("saved")
    }
}
