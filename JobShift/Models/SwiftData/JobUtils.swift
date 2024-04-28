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
}

struct JobBreak {
    var isActive: Bool = false
    var intervalMinutes: Int = 360
    var breakMinutes: Int = 45
}

struct JobWage {
    var start: Date = Date.distantPast
    var end: Date = Date.distantFuture
    var hourlyWage: Int = 1200
    var dailyWage: Int = 8000
}

struct JobSalary {
    struct History {
        var salary: Int
        var year: Int
        var month: Int
    }
    enum PaymentType {
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
    var cutOffDay: Int = 10
    var paymentDay: Int = 25
    var paymentType: PaymentType = .sameMonth
    var history: [History] = []
}

struct JobEventSummary {
    var eventId: String
    var summary: String
    var adjustment: Int?
}
