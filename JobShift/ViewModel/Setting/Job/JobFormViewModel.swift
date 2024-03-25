import Foundation
import Observation

@Observable class JobFormViewModel {
    var name: String = ""
    var color: JobColor = JobColor.red
    var isDailyWage: Bool = false {
        didSet { checkFirstWageError() }
    }
    var dailyWageString: String = "" {
        didSet {
            checkFirstWageError()
            if let dailyWage = Int(dailyWageString) {
                wages[0].dailyWage = dailyWage
            }
        }
    }
    var hourlyWageString: String = "" {
        didSet {
            checkFirstWageError()
            if let hourlyWage = Int(hourlyWageString) {
                wages[0].hourlyWage = hourlyWage
            }
        }
    }
    var startDate: Date = Calendar(identifier: .gregorian).date(from: DateComponents(year: 2_020, month: 4, day: 1)) ?? Date()
    var isCommuteWage: Bool = false
    var commuteWageString: String = ""
    var isNightWage: Bool = false
    var isHolidayWage: Bool = false
    var isBreak1: Bool = false
    var break1: Break = Break()
    var isBreak2: Bool = false
    var break2: Break = Break(breakMinutes: 60, breakIntervalMinutes: 480)
    var displayPaymentDay: Bool = true
    var salaryCutoffDay: Int = 10
    var salaryPaymentDay: Int = 25
    var firstWageError: Bool = true
    var wages: [Wage] = [Wage()]
    var showAddWageView: Bool = false
    var newWageString: String = ""
    var newWageDate: Date = Date()
    var newWageValidateError: Bool {
        return newWageString.isEmpty || Int(newWageString) == nil
    }
    private var job: Job?
    required init(job: Job?) {
        if let job = job {
            name = job.name
            color = job.color
            isDailyWage = job.isDailyWage
            dailyWageString = job.wages[0].dailyWage == 0 ? "" : String(job.wages[0].dailyWage)
            hourlyWageString = job.wages[0].hourlyWage == 0 ? "" : String(job.wages[0].hourlyWage)
            startDate = job.startDate
            isCommuteWage = job.isCommuteWage
            commuteWageString = job.commuteWage == 0 ? "" : String(job.commuteWage)
            isNightWage = job.isNightWage
            isHolidayWage = job.isHolidayWage
            isBreak1 = job.isBreak1
            break1 = job.break1
            isBreak2 = job.isBreak2
            break2 = job.break2
            displayPaymentDay = job.displayPaymentDay
            salaryCutoffDay = job.salaryCutoffDay
            salaryPaymentDay = job.salaryPaymentDay
            wages = job.wages
            self.job = job
        }
    }
    func checkFirstWageError() {
        if isDailyWage {
            firstWageError = Int(dailyWageString) == nil
        } else {
            firstWageError = Int(hourlyWageString) == nil
        }
    }
    
    func deleteWage(at: IndexSet) {
        wages.remove(atOffsets: at)
        sortWages()
    }
    
    func wagePlusButtonTapped() {
        showAddWageView = true
    }
    
    func addViewOnAppear() {
        sortWages()
    }
    
    func addSheetDismiss() {
        sortWages()
    }
    
    func addWage() {
        let newWage = Wage(
            hourlyWage: isDailyWage ? 0 : Int(newWageString)!,
            dailyWage: isDailyWage ? Int(newWageString)! : 0,
            start: newWageDate,
            end: Date.distantFuture)
        wages.append(newWage)
    }
    
    private func sortWages() {
        let calendar = Calendar.current
        var result = wages
        result.sort { $0.start < $1.start }
        for i in 0..<result.count {
            if i < result.count - 1 {
                let nextStart = result[i + 1].start
                let oneDayBefore = calendar.date(byAdding: .day, value: -1, to: nextStart)
                let endOfDay = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: oneDayBefore!)
                result[i].end = endOfDay!
            } else {
                result[i].end = Date.distantFuture
            }
        }
        result[0].start = startDate
        wages = result
        if job != nil {
            job!.wages = result
        }
    }
}
