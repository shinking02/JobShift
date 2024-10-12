import Foundation
import HolidayJp
import SwiftData
import SwiftUI

typealias Job = JobSchemaV4.Job
typealias OneTimeJob = JobSchemaV4.OneTimeJob

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

enum JobColor: String, Codable, CaseIterable {
    case red
    case orange
    case yellow
    case green
    case blue
    case purple
    case brown
    case pink
    case mint
}

extension JobColor {
    func japaneseColorName() -> String {
        switch self {
        case .red:
            return "レッド"
        case .orange:
            return "オレンジ"
        case .yellow:
            return "イエロー"
        case .green:
            return "グリーン"
        case .blue:
            return "ブルー"
        case .purple:
            return "パープル"
        case .brown:
            return "ブラウン"
        case .pink:
            return "ピンク"
        case .mint:
            return "ミント"
        }
    }
    
    func getColor() -> Color {
        switch self {
        case .red:
            return Color.red
        case .orange:
            return Color.orange
        case .yellow:
            return Color.yellow
        case .green:
            return Color.green
        case .blue:
            return Color.blue
        case .purple:
            return Color.purple
        case .brown:
            return Color.brown
        case .pink:
            return Color.pink
        case .mint:
            return Color.mint
        }
    }
}

enum JobSchemaV1: VersionedSchema {
    static var versionIdentifier = Schema.Version(1, 0, 0)
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
        var nightWageStartTime: Date = Date()
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
        var salaryHistories: [SalaryHistory] = []
        
        init(
            name: String = "",
            color: JobColor = JobColor.red,
            isDailyWage: Bool = false,
            dailyWage: Int = 10_000,
            isNightWage: Bool = false,
            nightWageStartTime: Date = Calendar(identifier: .gregorian).date(from: DateComponents(hour: 22)) ?? Date(),
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
            salaryHistories: [SalaryHistory] = []
        ) {
            self.id = UUID()
            self.name = name
            self.color = color
            self.isDailyWage = isDailyWage
            self.isNightWage = isNightWage
            self.nightWageStartTime = nightWageStartTime
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
        
        init(name: String = "", date: Date = Date(), salary: Int = 6_000, isCommuteWage: Bool = false, commuteWage: Int = 500) {
            self.id = UUID()
            self.name = name
            self.date = date
            self.salary = salary
            self.isCommuteWage = isCommuteWage
            self.commuteWage = commuteWage
        }
    }
}

enum JobSchemaV2: VersionedSchema {
    static var versionIdentifier = Schema.Version(1, 0, 1)
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
        var nightWageStartTime: Date = Date()
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
        var salaryHistories: [SalaryHistory] = []
        var eventSummaries: [String: String] = [:]
        
        init(
            name: String = "",
            color: JobColor = JobColor.red,
            isDailyWage: Bool = false,
            dailyWage: Int = 10_000,
            isNightWage: Bool = false,
            nightWageStartTime: Date = Calendar(identifier: .gregorian).date(from: DateComponents(hour: 22)) ?? Date(),
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
            eventSummaries: [String: String] = [:]
        ) {
            self.id = UUID()
            self.name = name
            self.color = color
            self.isDailyWage = isDailyWage
            self.isNightWage = isNightWage
            self.nightWageStartTime = nightWageStartTime
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
            self.eventSummaries = eventSummaries
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

enum JobSchemaV4: VersionedSchema {
    static var versionIdentifier = Schema.Version(1, 0, 3)
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
        var jobWages: [JobWage] = [JobWage(start: Date())]
        var salary: JobSalary = JobSalary()
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
            jobWages: [JobWage] = [JobWage(start: Date())],
            salary: JobSalary = JobSalary(),
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


enum JobSalaryType: Codable, CaseIterable {
    case daily
    case hourly
    
    func toString() -> String {
        switch self {
        case .daily:
            return "日給"
        case .hourly:
            return "時給"
        }
    }
}

struct JobBreak: Codable {
    var isActive: Bool = false
    var intervalMinutes: Int = 360
    var breakMinutes: Int = 45
}

struct JobWage: Codable, Identifiable, Equatable {
    var id: UUID = UUID()
    var start: Date = Date.distantPast
    var wage: Int = 1_200
}

struct History: Codable, Identifiable {
    var id: UUID = UUID()
    var salary: Int
    var year: Int
    var month: Int
}
enum PaymentType: Codable, CaseIterable, Equatable {
    case sameMonth
    case nextMonth
    
    func toString() -> String {
        switch self {
        case .sameMonth:
            "当月"
        case .nextMonth:
            "翌月"
        }
    }
}

struct JobSalary: Codable {
    var cutOffDay: Int? = 10
    var paymentDay: Int? = 25
    var paymentType: PaymentType? = .nextMonth
    var histories: [History]? = []
}

struct JobEventSummary: Codable {
    var eventId: String
    var summary: String
    var adjustment: Int?
}

enum JobMigrationPlan: SchemaMigrationPlan {
    static var schemas: [VersionedSchema.Type] {
        [
            JobSchemaV1.self,
            JobSchemaV2.self,
            JobSchemaV3.self,
            JobSchemaV4.self
        ]
    }
    static var stages: [MigrationStage] {
        [
            migrateV1toV2,
            migrateV2toV3,
            migrateV3toV4
        ]
    }
    static let migrateV1toV2 = MigrationStage.lightweight(fromVersion: JobSchemaV1.self, toVersion: JobSchemaV2.self)
    static let migrateV2toV3 = MigrationStage.custom(
        fromVersion: JobSchemaV2.self,
        toVersion: JobSchemaV3.self,
        willMigrate: nil
    ) { context in
        let jobs = try? context.fetch(FetchDescriptor<JobSchemaV3.Job>())
        jobs?.forEach { job in
            job.newEventSummaries = job.eventSummaries.map { EventSummary(eventId: $0.key, summary: $0.value) }
        }
        try? context.save()
    }
    
    static let migrateV3toV4 = MigrationStage.custom(
        fromVersion: JobSchemaV3.self,
        toVersion: JobSchemaV4.self,
        willMigrate: nil) { context in
            print("hogehogex")
            let jobs = try? context.fetch(FetchDescriptor<JobSchemaV4.Job>()) ?? []
        }

//    static var v3Jobs: [JobSchemaV3.Job] = []
//    static let migrateV3toV4 = MigrationStage.custom(
//        fromVersion: JobSchemaV3.self,
//        toVersion: JobSchemaV4.self,
//        willMigrate: { context in
//            v3Jobs = (try? context.fetch(FetchDescriptor<JobSchemaV3.Job>())) ?? []
//        },
//        didMigrate: { context in
//            let v4Jobs = try? context.fetch(FetchDescriptor<JobSchemaV4.Job>())
//            v4Jobs?.forEach { v4Job in
//                guard let v3Job = v3Jobs.first(where: { $0.id == v4Job.id }) else { return }
//                v4Job.salaryType = v3Job.isDailyWage ? .daily : .hourly
//                v4Job.breaks = [
//                    JobBreak(
//                        isActive: v3Job.isBreak1,
//                        intervalMinutes: v3Job.break1.breakIntervalMinutes,
//                        breakMinutes: v3Job.break2.breakMinutes
//                    ),
//                    JobBreak(
//                        isActive: v3Job.isBreak2,
//                        intervalMinutes: v3Job.break2.breakIntervalMinutes,
//                        breakMinutes: v3Job.break2.breakMinutes
//                    )
//                ]
//                v4Job.jobWages = v3Job.wages.map { wage in
//                    return JobWage(
//                        start: wage.start,
//                        wage: v3Job.isDailyWage ? wage.dailyWage : wage.hourlyWage
//                    )
//                }
//                v4Job.salary = JobSalary(
//                    cutOffDay: v3Job.salaryCutoffDay,
//                    paymentDay: v3Job.salaryPaymentDay,
//                    paymentType: .nextMonth,
//                    histories: v3Job.salaryHistories.map { history in
//                        return JobSalary.History(
//                            salary: history.salary,
//                            year: history.year,
//                            month: history.month
//                        )
//                    }
//                )
//                v4Job.eventSummaries = v3Job.newEventSummaries.map { eventSummary in
//                    return JobEventSummary(
//                        eventId: eventSummary.eventId,
//                        summary: eventSummary.summary,
//                        adjustment: eventSummary.adjustment
//                    )
//                }
//            }
//            try? context.save()
//        }
//    )
}
