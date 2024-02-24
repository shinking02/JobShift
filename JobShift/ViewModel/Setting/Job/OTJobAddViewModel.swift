import Foundation

class OTJobAddViewModel: ObservableObject {
    @Published var name: String = "" {
        didSet {
            validateFields()
        }
    }
    @Published var salary: String = "" {
        didSet {
            validateFields()
        }
    }
    @Published var commuteWage: String = "" {
        didSet {
            validateFields()
        }
    }
    @Published var date: Date = Date()
    @Published var isCommuteWage: Bool = false {
        didSet {
            validateFields()
        }
    }
    @Published var summary: String = ""
    @Published var validationError: Bool = true
    private var dataSource = SwiftDataSource.shared
    
    init() {
        validateFields()
    }
    
    func handleAddButton() {
        validateFields()
        if !validationError {
            let otJob = OneTimeJob(
                name: name,
                date: date,
                salary: Int(salary)!,
                isCommuteWage: isCommuteWage,
                commuteWage: Int(commuteWage) ?? 0,
                summary: summary
            )
            dataSource.appendOTJob(otJob)
        }
    }
    
    private func validateFields() {
        let isNameValid = !name.isEmpty
        let isSalaryValid = Int(salary) != nil
        let isCommuteWageValid = !isCommuteWage || Int(commuteWage) != nil
        validationError = !isNameValid || !isSalaryValid || !isCommuteWageValid
    }
}
