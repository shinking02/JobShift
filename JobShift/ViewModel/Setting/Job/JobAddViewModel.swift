import Foundation

class JobAddViewModel: JobBaseViewModel {
    func handleAddButton() {
        let job = Job(
            name: name,
            color: color,
            isDailyWage: isDailyWage,
            isNightWage: isNightWage,
            isHolidayWage: isHolidayWage,
            wages: wages,
            isCommuteWage: isCommuteWage,
            isBreak1: isBreak1,
            break1: break1, isBreak2: isBreak2,
            break2: break2,
            salaryCutoffDay: salaryCutoffDay,
            salaryPaymentDay: salaryPaymentDay,
            displayPaymentDay: displayPaymentDay,
            startDate: startDate
        )
        dataSource.appendJob(job)
    }
}
