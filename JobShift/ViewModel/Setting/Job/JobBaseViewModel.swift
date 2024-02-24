import Foundation

class JobBaseViewModel: ObservableObject {
    @Published var name: String = "" {
        didSet {
            validateFields()
        }
    }
    @Published var color: JobColor = .red
    @Published var isDailyWage: Bool = false {
        didSet {
            validateFields()
        }
    }
    @Published var isNightWage: Bool = false
    @Published var isHolidayWage: Bool = false
    @Published var isCommuteWage: Bool = false {
        didSet {
            validateFields()
        }
    }
    @Published var dailyWageString: String = "" {
        didSet {
            validateFields()
            setFirstWage()
        }
    }
    @Published var hourlyWageString: String = "" {
        didSet {
            validateFields()
            setFirstWage()
        }
    }
    @Published var startDate: Date = Calendar(identifier: .gregorian).date(from: DateComponents(year: 2020, month: 4, day: 1)) ?? Date() {
        didSet {
            setFirstWage()
        }
    }
    @Published var wages: [Wage] = []
    @Published var commuteWageString: String = "" {
        didSet {
            validateFields()
        }
    }
    @Published var isBreak1: Bool = false
    @Published var isBreak2: Bool = false
    @Published var break1: Break = Break(breakMinutes: 45, breakIntervalMinutes: 360)
    @Published var break2: Break = Break(breakMinutes: 60, breakIntervalMinutes: 480)
    @Published var salaryCutoffDay: Int = 10
    @Published var salaryPaymentDay: Int = 25
    @Published var displayPaymentDay: Bool = true
    @Published var firstWageError: Bool = true
    @Published var validationError: Bool = true
    @Published var newWageDate: Date = Date()
    @Published var newWageString: String = "" {
        didSet {
            newWageValidateError = Int(newWageString) == nil
        }
    }
    @Published var newWageValidateError: Bool = true
    var dataSource = SwiftDataSource.shared
    
    init() {
        validateFields()
    }
    
    private func setFirstWage() {
        if (!isDailyWage && hourlyWageString.isEmpty) || (isDailyWage && dailyWageString.isEmpty) {
            firstWageError = true
            return
        }
        firstWageError = false
        let wage = Wage(hourlyWage: Int(hourlyWageString) ?? 0, dailyWage: Int(dailyWageString) ?? 0, start: startDate, end: Date.distantFuture)
        if wages.isEmpty {
            wages.append(wage)
        } else {
            wages[0] = wage
        }
    }
    
    private func validateFields() {
        let isNameValid = !name.isEmpty
        let isHourlyWageValid = isDailyWage || Int(hourlyWageString) != nil
        let isDailyWageValid = !isDailyWage || Int(dailyWageString) != nil
        let isCommuteWageValid = !isCommuteWage || Int(commuteWageString) != nil
        validationError = !isNameValid || !isCommuteWageValid || !isHourlyWageValid || !isDailyWageValid
    }
    
    func sortAndUpdateWages() {
        let calendar = Calendar.current
        wages.sort { $0.start < $1.start }
        for i in 0..<wages.count {
            if i < wages.count - 1 {
                let nextStart = wages[i + 1].start
                let oneDayBefore = calendar.date(byAdding: .day, value: -1, to: nextStart)
                let endOfDay = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: oneDayBefore!)
                wages[i].end = endOfDay!
            } else {
                wages[i].end = Date.distantFuture
            }
        }
        wages[0].start = startDate
    }
    
    func addNewWage() {
        if newWageValidateError {
            return
        }
        let newWage = Wage(hourlyWage: !isDailyWage ? Int(newWageString)! : 0, dailyWage: isDailyWage ? Int(newWageString)! : 0, start: newWageDate, end: Date.distantFuture)
        wages.append(newWage)
        sortAndUpdateWages()
        newWageString = ""
    }
    
    func deleteWage(at offsets: IndexSet) {
        wages.remove(atOffsets: offsets)
        sortAndUpdateWages()
    }
}
