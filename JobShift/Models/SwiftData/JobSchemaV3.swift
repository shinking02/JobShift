import SwiftUI
import SwiftData

struct Salary: Identifiable {
    let id = UUID()
    var year: Int
    var month: Int
    var job: Job?
    var totalSalary: Int
    var totalMinutes: Int
    var attendanceCount: Int
    var isConfirm: Bool
    var confirmTotal: Int
    var commuteWage: Int
    var details: [SalaryDetail]
}

struct SalaryDetail: Hashable {
    var event: Event
    var dateText: String
    var startText: String
    var endText: String
    var summary: String
    var salary: Int
    var hasAdjustment: Bool
}

struct Wage: Codable, Hashable {
    var hourlyWage: Int
    var dailyWage: Int
    var start: Date
    var end: Date
    init(hourlyWage: Int = 1_200, dailyWage: Int = 10_000, start: Date = Date.distantPast, end: Date = Date.distantFuture) {
        self.hourlyWage = hourlyWage
        self.dailyWage = dailyWage
        self.start = start
        self.end = end
    }
}

struct Break: Codable {
    var breakMinutes: Int
    var breakIntervalMinutes: Int
    init(breakMinutes: Int = 45, breakIntervalMinutes: Int = 360) {
        self.breakMinutes = breakMinutes
        self.breakIntervalMinutes = breakIntervalMinutes
    }
}

struct EventSummary: Codable, Hashable {
    var eventId: String
    var summary: String
    var adjustment: Int?
}

struct SalaryHistory: Hashable, Codable {
    var salary: Int
    var year: Int
    var month: Int
}

enum JobSchemaV3: VersionedSchema {
    static var versionIdentifier = Schema.Version(1, 0, 2)
    static var models: [any PersistentModel.Type] {
        [Job.self, OneTimeJob.self]
    }
    
    @Model
    final class Job {
        let id: UUID = UUID()
        var name: String = ""
        var color: JobColor = JobColor.red
        var isDailyWage: Bool = false
        var isNightWage: Bool = false
        var isHolidayWage: Bool = false
        var wages: [Wage] = []
        var isCommuteWage: Bool = false
        var commuteWage: Int = 0
        var isBreak1: Bool = false
        var break1: Break = Break(breakMinutes: 0, breakIntervalMinutes: 0)
        var isBreak2: Bool = false
        var break2: Break = Break(breakMinutes: 0, breakIntervalMinutes: 0)
        var salaryCutoffDay: Int = 0
        var salaryPaymentDay: Int = 0
        var displayPaymentDay: Bool = true
        var startDate: Date = Date.distantPast
        var salaryHistories: [SalaryHistory] = []
        var eventSummaries: [String: String] = [:]
        var newEventSummaries: [EventSummary] = []
        var recentlySalary: Int = 0
        
        init(
            name: String = "",
            color: JobColor = JobColor.red,
            isDailyWage: Bool = false,
            dailyWage: Int = 10_000,
            isNightWage: Bool = false,
            isHolidayWage: Bool = false,
            wages: [Wage] = [Wage()],
            isCommuteWage: Bool = false,
            commuteWage: Int = 500,
            isBreak1: Bool = false,
            break1: Break = Break(breakMinutes: 60, breakIntervalMinutes: 360),
            isBreak2: Bool = false,
            break2: Break = Break(breakMinutes: 90, breakIntervalMinutes: 480),
            salaryCutoffDay: Int = 20,
            salaryPaymentDay: Int = 10,
            salaryHistories: [SalaryHistory] = [],
            newEventSummaries: [EventSummary] = [],
            displayPaymentDay: Bool = true,
            startDate: Date = Calendar(identifier: .gregorian).date(from: DateComponents(year: 2_020, month: 4, day: 1)) ?? Date()
        ) {
            self.id = UUID()
            self.name = name
            self.color = color
            self.isDailyWage = isDailyWage
            self.isNightWage = isNightWage
            self.isHolidayWage = isHolidayWage
            self.wages = wages
            self.isCommuteWage = isCommuteWage
            self.commuteWage = commuteWage
            self.isBreak1 = isBreak1
            self.break1 = break1
            self.isBreak2 = isBreak2
            self.break2 = break2
            self.salaryCutoffDay = salaryCutoffDay
            self.salaryPaymentDay = salaryPaymentDay
            self.salaryHistories = salaryHistories
            self.newEventSummaries = newEventSummaries
            self.displayPaymentDay = displayPaymentDay
            self.startDate = startDate
        }
    }
    
    @Model
    final class OneTimeJob {
        let id: UUID = UUID()
        var name: String = ""
        var date: Date = Date()
        var salary: Int = 0
        var isCommuteWage: Bool = false
        var commuteWage: Int = 0
        var summary: String = ""
        
        init(name: String = "", date: Date = Date(), salary: Int = 6_000, isCommuteWage: Bool = false, commuteWage: Int = 500, summary: String = "") {
            self.id = UUID()
            self.name = name
            self.date = date
            self.salary = salary
            self.isCommuteWage = isCommuteWage
            self.commuteWage = commuteWage
            self.summary = summary
        }
    }
}
