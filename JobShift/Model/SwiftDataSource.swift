import SwiftData

final class SwiftDataSource {
    private let modelContainer: ModelContainer
    private let modelContext: ModelContext

    @MainActor
    static let shared = SwiftDataSource()

    @MainActor
    private init() {
        self.modelContainer = try! ModelContainer(for: Job.self, OneTimeJob.self, migrationPlan: JobMigrationPlan.self)
        self.modelContext = modelContainer.mainContext
    }

    func appendJob(_ job: Job) {
        modelContext.insert(job)
        do {
            try modelContext.save()
        } catch {
            fatalError(error.localizedDescription)
        }
    }

    func fetchJobs() -> [Job] {
        do {
            return try modelContext.fetch(FetchDescriptor<Job>())
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    func removeJob(_ job: Job) {
        modelContext.delete(job)
    }
    
    func appendOTJob(_ otJob: OneTimeJob) {
        modelContext.insert(otJob)
        do {
            try modelContext.save()
        } catch {
            fatalError(error.localizedDescription)
        }
    }

    func fetchOTJobs() -> [OneTimeJob] {
        do {
            return try modelContext.fetch(FetchDescriptor<OneTimeJob>())
        } catch {
            fatalError(error.localizedDescription)
        }
    }

    func removeOTJob(_ otJob: OneTimeJob) {
        modelContext.delete(otJob)
    }
}
