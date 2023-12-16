import Foundation
import SwiftData

@Model
final class OneTimeJob {
    let id: UUID
    var name: String
    var date: Date
    var salary: Int
    var commuteWage: Int?
    
    init(name: String, date: Date, salary: Int, commuteWage: Int? = nil) {
        self.id = UUID()
        self.name = name
        self.date = date
        self.salary = salary
        self.commuteWage = commuteWage
    }
}
