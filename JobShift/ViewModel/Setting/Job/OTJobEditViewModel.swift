import Observation

@Observable final class OTJobEditViewModel: OTJobFormViewModel {
    var showDeleteAlert = false
    var otJob: OneTimeJob
    required init(otJob: OneTimeJob?) {
        self.otJob = otJob ?? OneTimeJob()
        super.init(otJob: otJob)
    }
    func deleteButtonTapped() {
        showDeleteAlert = true
    }
    func delete() {
        let swiftDataSource = SwiftDataSource.shared
        swiftDataSource.removeOTJob(otJob)
    }
    func onDisappear() {
        otJob.name = name.isEmpty ? otJob.name : name
        otJob.salary = Int(salaryString) ?? 0
        otJob.isCommuteWage = isCommuteWage && Int(commuteWageString) != nil
        otJob.commuteWage = Int(commuteWageString) ?? 0
        otJob.date = date
        otJob.summary = summary
        SwiftDataSource.shared.save()
    }
}
