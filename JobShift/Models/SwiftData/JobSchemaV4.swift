import Foundation
import SwiftData

enum JobSchemaV4: VersionedSchema {
    static var versionIdentifier = Schema.Version(1, 0, 4)
    static var models: [any PersistentModel.Type] {
        [Job.self, OneTimeJob.self]
    }
    
    @Model
    final class Job {
        let id: UUID = UUID()
        var name: String = ""
        var color: JobColor = JobColor.red
        var salaryType: JobSalaryType = JobSalaryType.hourly
        var isNightWage: Bool = false
        var isHolidayWage: Bool = false
        var isCommuteWage: Bool = false
        var commuteWage: Int = 500
        var breaks: [JobBreak] = [JobBreak(), JobBreak()]
        var jobWages: [JobWage] = [JobWage(start: Date(year: 2010, month: 4, day: 1))]
        var salaryCutOffDay: Int = 10
        var salaryPaymentDay: Int = 25
        var salaryPaymentType: SalaryPaymentType = SalaryPaymentType.nextMonth
        var salaryHistoriesV2: [JobSalaryHistory] = []
        var eventSummaries: [JobEventSummary] = []
        var displayPaymentDay: Bool = true
        var order: Int = 0
        
        init(
            name: String = "",
            color: JobColor = JobColor.red,
            salaryType: JobSalaryType = JobSalaryType.hourly,
            isNightWage: Bool = false,
            isHolidayWage: Bool = false,
            isCommuteWage: Bool = false,
            commuteWage: Int = 500,
            breaks: [JobBreak] = [JobBreak(), JobBreak()],
            jobWages: [JobWage] = [JobWage(start: Date(year: 2_010, month: 4, day: 1))],
            salaryCutOffDay: Int = 10,
            salaryPaymentDay: Int = 25,
            salaryPaymentType: SalaryPaymentType = SalaryPaymentType.nextMonth,
            salaryHistoriesV2: [JobSalaryHistory] = [],
            eventSummaries: [JobEventSummary] = [],
            displayPaymentDay: Bool = true,
            order: Int = 0
        ) {
            self.name = name
            self.color = color
            self.salaryType = salaryType
            self.isNightWage = isNightWage
            self.isHolidayWage = isHolidayWage
            self.isCommuteWage = isCommuteWage
            self.commuteWage = commuteWage
            self.breaks = breaks
            self.jobWages = jobWages
            self.salaryCutOffDay = salaryCutOffDay
            self.salaryPaymentDay = salaryPaymentDay
            self.salaryPaymentType = salaryPaymentType
            self.salaryHistoriesV2 = salaryHistoriesV2
            self.eventSummaries = eventSummaries
            self.displayPaymentDay = displayPaymentDay
            self.order = order
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
