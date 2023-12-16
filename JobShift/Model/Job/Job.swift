import Foundation
import SwiftData
import SwiftUI

@Model
final class Job {
    let id: UUID
    var name: String
    var color: JobColor
    var isDailyWage: Bool
    var dailyWage: Int
    var isNightWage: Bool
    var nightWageStartTime: Date
    var isHolidayWage: Bool
    var wages: [Wage]
    var isCommuteWage: Bool
    var commuteWage: Int
    var isBreak1: Bool
    var break1: Break
    var isBreak2: Bool
    var break2: Break
    var salaryCutoffDay: Int
    var salaryPaymentDay: Int
    var salaries: [Salary]
    
    init(
        name: String = "",
        color: JobColor = JobColor.red,
        isDailyWage: Bool = false,
        dailyWage: Int = 10000,
        isNightWage: Bool = false,
        nightWageStartTime: Date = Calendar(identifier: .gregorian).date(from: DateComponents(hour: 22)) ?? Date(),
        isHolidayWage: Bool = false,
        wages: [Wage] = [Wage(hourlyWage: 1200, nightHourlyWage: 1300, holidayHourlyWage: 1300, holidayHourlyNightWage: 1400, start: nil, end: nil)],
        isCommuteWage: Bool = false,
        commuteWage: Int = 500,
        isBreak1: Bool = false,
        break1: Break = Break(breakMinutes: 60, breakIntervalMinutes: 360),
        isBreak2: Bool = false,
        break2: Break = Break(breakMinutes: 90, breakIntervalMinutes: 480),
        salaryCutoffDay: Int = 20,
        salaryPaymentDay: Int = 10,
        salaries: [Salary] = []
    ) {
        self.id = UUID()
        self.name = name
        self.color = color
        self.isDailyWage = isDailyWage
        self.dailyWage = dailyWage
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
        self.salaries = salaries
    }
}

struct Wage: Codable, Hashable {
    var hourlyWage: Int
    var nightHourlyWage: Int
    var holidayHourlyWage: Int
    var holidayHourlyNightWage: Int
    var start: DateComponents?
    var end: DateComponents?
}

struct Break: Codable {
    var breakMinutes: Int
    var breakIntervalMinutes: Int
}

struct Salary: Codable {
    var salary: Int
    var yearMonth: DateComponents
}

enum JobColor: String, Codable, CaseIterable {
    case red
    case orange
    case yellow
    case green
    case blue
    case purple
    case brown
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
        }
    }
}
