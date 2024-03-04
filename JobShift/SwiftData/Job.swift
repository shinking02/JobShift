import Foundation
import SwiftData
import SwiftUI
import HolidayJp

typealias Job = JobSchemaV3.Job
typealias OneTimeJob = JobSchemaV3.OneTimeJob

extension Job {
    func getSalaryPaymentDay(year: Int, month: Int) -> Date? {
        let calendar = Calendar.current
        var dateComp = DateComponents(calendar: calendar, year: year, month: month, day: self.salaryPaymentDay)
        // 給料日が存在しない場合は、月末日をセット
        if dateComp.month != month {
            dateComp.day = 0
        }
        // 祝日・土日の場合は、直前の平日を取得
        while let date = dateComp.date {
            if date.isHoliday() {
                let previousDate = calendar.date(byAdding: .day, value: -1, to: date)
                dateComp = calendar.dateComponents(in: TimeZone.current, from: previousDate!)
            } else {
                break
            }
        }
        
        if calendar.compare(dateComp.date!, to: self.startDate, toGranularity: .day) == .orderedAscending {
            return nil
        }
        return calendar.date(from: dateComp)!
    }
}

struct Wage: Codable, Hashable {
    var hourlyWage: Int
    var dailyWage: Int
    var start: Date
    var end: Date
    init(hourlyWage: Int = 1200, dailyWage: Int = 10000, start: Date = Date.distantPast, end: Date = Date.distantFuture) {
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

struct EventSummary: Codable {
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
            dailyWage: Int = 10000,
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
        
        init(name: String = "", date: Date = Date(), salary: Int = 6000, isCommuteWage: Bool = false, commuteWage: Int = 500) {
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
            dailyWage: Int = 10000,
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
        
        init(name: String = "", date: Date = Date(), salary: Int = 6000, isCommuteWage: Bool = false, commuteWage: Int = 500, summary: String = "") {
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
        @Attribute(originalName: "eventSummaries") var eventSummariesOld: [String: String] = [:]
        var eventSummaries: [EventSummary] = []
        var lastAccessedTime: Date = Date()
        
        init(
            name: String = "",
            color: JobColor = JobColor.red,
            isDailyWage: Bool = false,
            dailyWage: Int = 10000,
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
            eventSummaries: [EventSummary] = [],
            lastAccessedTime: Date = Date(),
            displayPaymentDay: Bool = true,
            startDate: Date = Date.distantPast
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
            self.eventSummaries = eventSummaries
            self.lastAccessedTime = lastAccessedTime
            self.displayPaymentDay = displayPaymentDay
            self.lastAccessedTime = Date()
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
        
        init(name: String = "", date: Date = Date(), salary: Int = 6000, isCommuteWage: Bool = false, commuteWage: Int = 500, summary: String = "") {
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

enum JobMigrationPlan: SchemaMigrationPlan {
    static var schemas: [VersionedSchema.Type] {
        [
            JobSchemaV1.self,
            JobSchemaV2.self,
            JobSchemaV3.self
        ]
    }
    static var stages: [MigrationStage] {
        [
            migrateV1toV2,
            migrateV2toV3
        ]
    }
    static let migrateV1toV2 = MigrationStage.lightweight(fromVersion: JobSchemaV1.self, toVersion: JobSchemaV2.self)
    static let migrateV2toV3 = MigrationStage.custom(
        fromVersion: JobSchemaV2.self,
        toVersion: JobSchemaV3.self,
        willMigrate: nil,
        didMigrate: { context in
            let jobs = try? context.fetch(FetchDescriptor<JobSchemaV3.Job>())
            jobs?.forEach { job in
                job.eventSummaries = job.eventSummariesOld.map { EventSummary(eventId: $0.key, summary: $0.value) }
            }
            try? context.save()
        }
    )
}


