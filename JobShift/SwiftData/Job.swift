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

    func getMonthSalary(year: Int, month: Int) -> Salary {
        let interval = getWorkDayInterval(year: year, month: month)
        let targetEvents = EventStore.shared.getJobEvents(interval: interval, jobName: self.name)
        var totalSalary = 0
        var totalMinutes = 0
        var details: [SalaryDetail] = []
        
        targetEvents.forEach { event in
            let (salary, minutes) = calculateEventSalary(event)
            totalSalary += salary
            totalMinutes += minutes
            details.append(SalaryDetail(
                event: event,
                dateText: event.start.toMdEString(brackets: true),
                startText: event.isAllDay ? "終日" : event.start.toHmmString(),
                endText: event.isAllDay ? "" : event.end.toHmmString(),
                summary: self.eventSummaries.first { $0.eventId == event.id }?.summary ?? "",
                salary: salary,
                hasAdjustment: self.eventSummaries.first { $0.eventId == event.id }?.adjustment != nil
            ))
        }
        let confirmTotal = self.salaryHistories.first { $0.year == year && $0.month == month }?.salary ?? nil
        return Salary(
            year: year,
            month: month,
            job: self,
            totalSalary: totalSalary,
            totalMinutes: totalMinutes,
            count: targetEvents.count,
            isConfirm: confirmTotal != nil || interval.end < self.startDate,
            confirmTotal: confirmTotal ?? 0,
            commuteWage: self.isCommuteWage ? details.count * self.commuteWage : 0,
            details: details
        )
    }
    
    func getYearSalary(year: Int) -> [Salary] {
        var salaries: [Salary] = []
        for month in 1...12 {
            let salary = getMonthSalary(year: year, month: month)
            salaries.append(salary)
        }
        return salaries
    }
    
    func getWorkDayInterval(year: Int, month: Int?) -> DateInterval {
        let currendar = Calendar.current
        if let month = month {
            let startComponents = {
                let tempStart = DateComponents(year: year, month: month - 1, day: 1)
                let startMonthDays = currendar.daysInMonth(for: currendar.date(from: tempStart)!)
                if startMonthDays < self.salaryCutoffDay + 1 {
                    return DateComponents(year: year, month: month, day: 1)
                } else {
                    return DateComponents(year: year, month: month - 1, day: self.salaryCutoffDay + 1)
                }
            }()
            let endComponents = {
                let tempEnd = DateComponents(year: year, month: month,  day: 1)
                let endMonthDays = currendar.daysInMonth(for: currendar.date(from: tempEnd)!)
                if endMonthDays < self.salaryCutoffDay {
                    return DateComponents(year: year, month: month + 1, day: 0, hour: 23, minute: 59)
                } else {
                    return DateComponents(year: year, month: month, day: self.salaryCutoffDay, hour: 23, minute: 59)
                }
            }()
            return DateInterval(start: currendar.date(from: startComponents)!, end: currendar.date(from: endComponents)!)
        } else {
            let startComponents = DateComponents(year: year - 1, month: 12, day: self.salaryCutoffDay + 1)
            let endComponents = DateComponents(year: year, month: 12, day: self.salaryCutoffDay)
            return DateInterval(start: max(currendar.date(from: startComponents)!, self.startDate), end: currendar.date(from: endComponents)!)
        }
    }
    
    private func calculateEventSalary(_ event: Event) -> (salary: Int, minutes: Int) {
        let wage = self.wages.first { $0.start <= event.start && event.start < $0.end }!
        var totalMinutes = event.end.timeIntervalSince(event.start) / 60
        if totalMinutes == 0 && event.isAllDay {
            totalMinutes = 24 * 60 // １日の終日イベントは開始と終了が同じになっている
        }
        let adjustment = self.eventSummaries.first { $0.eventId == event.id }?.adjustment ?? 0
        if self.isDailyWage {
            if self.isHolidayWage && event.start.isHoliday() {
                return (Int(Double(wage.dailyWage) * 1.35) + adjustment, Int(totalMinutes))
            }
            return (wage.dailyWage + adjustment, Int(totalMinutes))
        }
        let nightStandard = {
            let calendar = Calendar.current
            var components = calendar.dateComponents([.year, .month, .day], from: event.start)
            components.hour = 22
            components.minute = 0
            components.second = 0
            return calendar.date(from: components)!
        }()
        var nightMinutes = max(0, min(event.end.timeIntervalSince(nightStandard) / 60, totalMinutes, 420))
        var normalMinutes = totalMinutes - nightMinutes
        let normalRate = self.isHolidayWage && event.start.isHoliday() ? 1.35 : 1
        let nightRate = self.isNightWage ? normalRate + 0.25 : normalRate
        
        let break1 = self.isBreak1 ? self.break1 : nil
        let break2 = self.isBreak2 ? self.break2 : nil
        let targetBreak = [break1, break2]
            .compactMap { $0 }
            .filter { Double($0.breakIntervalMinutes) <= totalMinutes }
            .sorted { $0.breakIntervalMinutes < $1.breakIntervalMinutes }
            .last
        var breakMinutes = 0.0
        var tmpTotalMinutes = totalMinutes
        while let targetBreak = targetBreak, Double(targetBreak.breakIntervalMinutes) <= tmpTotalMinutes {
            breakMinutes += Double(targetBreak.breakMinutes)
            tmpTotalMinutes -= Double(targetBreak.breakIntervalMinutes + targetBreak.breakMinutes)
        }
        if breakMinutes <= normalMinutes {
            normalMinutes -= breakMinutes
        } else {
            breakMinutes -= normalMinutes
            normalMinutes = 0
            nightMinutes -= breakMinutes
        }
        let normalSalary: Int = Int(Double(wage.hourlyWage) * normalRate * normalMinutes / 60)
        let nightSalary: Int = Int(Double(wage.hourlyWage) * nightRate * nightMinutes / 60)
        return (normalSalary + nightSalary + adjustment, Int(totalMinutes - breakMinutes))
    }
}

struct Salary: Identifiable {
    let id = UUID()
    var year: Int
    var month: Int
    var job: Job?
    var totalSalary: Int
    var totalMinutes: Int
    var count: Int
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
        var recentlySalary: Int = 0
        
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
            startDate: Date = Calendar(identifier: .gregorian).date(from: DateComponents(year: 2020, month: 4, day: 1)) ?? Date()
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


