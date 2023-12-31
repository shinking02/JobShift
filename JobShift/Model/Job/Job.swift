import Foundation
import SwiftData
import SwiftUI

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

struct Wage: Codable, Hashable {
    var hourlyWage: Int
    var nightHourlyWage: Int
    var holidayHourlyWage: Int
    var holidayHourlyNightWage: Int
    var dailyWage: Int
    var start: Date
    var end: Date
    init(hourlyWage: Int = 1200, nightHourlyWage: Int = 1300, holidayHourlyWage: Int = 1300, holidayHourlyNightWage: Int = 1400, dailyWage: Int = 10000, start: Date = Date.distantPast, end: Date = Date.distantFuture) {
        self.hourlyWage = hourlyWage
        self.nightHourlyWage = nightHourlyWage
        self.holidayHourlyWage = holidayHourlyWage
        self.holidayHourlyNightWage = holidayHourlyNightWage
        self.dailyWage = dailyWage
        self.start = start
        self.end = end
    }
}

struct Break: Codable {
    var breakMinutes: Int
    var breakIntervalMinutes: Int
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
