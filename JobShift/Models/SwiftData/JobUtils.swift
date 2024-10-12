import Foundation
import SwiftUI

typealias Job = JobSchemaV4.Job
typealias OneTimeJob = JobSchemaV4.OneTimeJob

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
    func toColor() -> Color {
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
    
    func toString() -> String {
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

struct JobSalaryHistory: Codable, Identifiable {
    var id: UUID = UUID()
    var salary: Int
    var year: Int
    var month: Int
}

enum SalaryPaymentType: Codable, CaseIterable, Equatable {
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
    var cutOffDay: Int = 10
    var paymentDay: Int = 25
    var paymentType: SalaryPaymentType = .nextMonth
    var histories: [JobSalaryHistory] = []
}

struct JobEventSummary: Codable {
    var eventId: String
    var summary: String
    var adjustment: Int?
}
