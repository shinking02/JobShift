import Observation
import Foundation

@Observable class OTJobFormViewModel {
    var name: String = ""
    var salaryString: String = ""
    var date: Date = Date()
    var isCommuteWage: Bool = false
    var commuteWageString: String = ""
    var summary: String = ""
    
    required init(otJob: OneTimeJob?) {
        if let otJob = otJob {
            name = otJob.name
            salaryString = otJob.salary == 0 ? "" : String(otJob.salary)
            date = otJob.date
            isCommuteWage = otJob.isCommuteWage
            commuteWageString = otJob.commuteWage == 0 ? "" : String(otJob.commuteWage)
            summary = otJob.summary
        }
    }
}
