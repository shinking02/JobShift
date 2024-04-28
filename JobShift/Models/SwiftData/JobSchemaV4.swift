import Foundation
import SwiftData

enum JobSchemaV4: VersionedSchema {
    static var versionIdentifier = Schema.Version(2, 0, 0)
    static var models: [any PersistentModel.Type] {
        [Job.self, OneTimeJob.self]
    }
    
    @Model
    final class Job {
        let id: UUID = UUID()
        var name: String = ""
        var color: JobColor = JobColor.red
        var startDate: Date = Date(year: 2010, month: 4, day: 1)
        var isDailyWage: Bool = false
        var isNightWage: Bool = false
        var isHolidayWage: Bool = false
        var isCommuteWage: Bool = false
        var commuteWage: Int = 500
        var breaks: (JobBreak, JobBreak) = (JobBreak(), JobBreak())
        var wages: [JobWage] = []
        var salary: JobSalary = JobSalary()
        var eventSummaries: [JobEventSummary] = []
        var displayPaymentDay: Bool = true
        var order: Int = 0
        
        init(
            name: String = "",
            color: JobColor = JobColor.red,
            startDate: Date = Date(year: 2010, month: 4, day: 1),
            isDailyWage: Bool = false,
            isNightWage: Bool = false,
            isHolidayWage: Bool = false,
            isCommuteWage: Bool = false,
            commuteWage: Int = 500,
            breaks: (JobBreak, JobBreak) = (JobBreak(), JobBreak()),
            wages: [JobWage] = [],
            salary: JobSalary = JobSalary(),
            eventSummaries: [JobEventSummary] = [],
            displayPaymentDay: Bool = true,
            order: Int = 0
        ) {
            self.name = name
            self.color = color
            self.startDate = startDate
            self.isDailyWage = isDailyWage
            self.isNightWage = isNightWage
            self.isHolidayWage = isHolidayWage
            self.isCommuteWage = isCommuteWage
            self.commuteWage = commuteWage
            self.breaks = breaks
            self.wages = wages
            self.salary = salary
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
        var salary: Int = 9000
        var isCommuteWage: Bool = false
        var commuteWage: Int = 500
        var summary: String = ""
        
        init(
            name: String = "",
            date: Date = Date(),
            salary: Int = 9000,
            isCommuteWage: Bool = false,
            commuteWage: Int = 500,
            summary: String = ""
        ) {
            self.name = name
            self.date = date
            self.salary = salary
            self.isCommuteWage = isCommuteWage
            self.commuteWage = commuteWage
            self.summary = summary
        }
    }
}
