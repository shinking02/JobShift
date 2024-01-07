import Foundation
import SwiftData

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
