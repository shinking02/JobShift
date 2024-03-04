import Observation

@Observable final class JobAddViewModel: JobFormViewModel {
    required init(job: Job? = nil) {
        super.init(job: nil)
    }
    var validationError: Bool {
        if name.isEmpty {
            return true
        }
        if isCommuteWage {
            return Int(commuteWageString) == nil
        }
        if isDailyWage {
            return Int(dailyWageString) == nil
        } else {
            return Int(hourlyWageString) == nil
        }
    }
    func addButtonTapped() {
        let swiftDataSource = SwiftDataSource.shared
        let job = Job(
            name: name,
            color: color,
            isDailyWage: isDailyWage,
            isNightWage: isNightWage,
            isHolidayWage: isHolidayWage,
            isCommuteWage: isCommuteWage,
            commuteWage: Int(commuteWageString) ?? 0,
            isBreak1: isBreak1,
            break1: break1,
            isBreak2: isBreak2,
            break2: break2,
            salaryCutoffDay: salaryCutoffDay,
            salaryPaymentDay: salaryPaymentDay,
            displayPaymentDay: displayPaymentDay,
            startDate: startDate
        )
        swiftDataSource.appendJob(job)
    }
}
