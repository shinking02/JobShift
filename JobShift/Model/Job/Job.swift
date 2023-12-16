import Foundation
import SwiftData
import SwiftUI

@Model
final class Job {
    var name: String
    var color: JobColor
    var dailyWage: Int?
    var isNightWage: Bool
    var isHolidayWage: Bool
    var wages: [Wage]
    var commuteWage: Int?
    var break1: Break?
    var break2: Break?
    var salaryCutoffDay: Int
    var salaryPaymentDay: Int
    
    init(name: String, color: JobColor, dailyWage: Int? = nil, isNightWage: Bool, isHolidayWage: Bool, wages: [Wage], commuteWage: Int? = nil, break1: Break? = nil, break2: Break? = nil, salaryCutoffDay: Int, salaryPaymentDay: Int) {
        self.name = name
        self.color = color
        self.dailyWage = dailyWage
        self.isNightWage = isNightWage
        self.isHolidayWage = isHolidayWage
        self.wages = wages
        self.commuteWage = commuteWage
        self.break1 = break1
        self.break2 = break2
        self.salaryCutoffDay = salaryCutoffDay
        self.salaryPaymentDay = salaryPaymentDay
    }
}

struct Wage: Codable {
    var hourlyWage: Int
    var nightHourlyWage: Int?
    var holidayHourlyWage: Int?
    var interval: DateInterval
}

struct Break: Codable {
    var breakMinutes: Int
    var breakIntervalMinutes: Int
}

enum JobColor: String, Codable {
    case red
    case blue
    case green
}

extension JobColor {
    func japaneseColorName() -> String {
        switch self {
        case .red:
            return "レッド"
        case .blue:
            return "ブルー"
        case .green:
            return "グリーン"
        }
    }
    
    func getColor() -> Color {
        switch self {
        case .red:
            return Color.red
        case .blue:
            return Color.blue
        case .green:
            return Color.green
        }
    }
}
