import Foundation
import SwiftData

@Model
final class OneTimeJob {
    let id: UUID
    var name: String
    var date: Date
    var salary: Int
    var isCommuteWage: Bool
    var commuteWage: Int
    
    init(name: String = "", date: Date = Date(), salary: Int = 6000, isCommuteWage: Bool = false, commuteWage: Int = 500) {
        self.id = UUID()
        self.name = name
        self.date = date
        self.salary = salary
        self.isCommuteWage = isCommuteWage
        self.commuteWage = commuteWage
    }
}
