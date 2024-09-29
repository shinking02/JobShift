import Foundation
import SwiftData

enum JobMigrationPlan: SchemaMigrationPlan {
    static var schemas: [VersionedSchema.Type] {
        [
            JobSchemaV1.self,
            JobSchemaV2.self,
            JobSchemaV3.self,
            JobSchemaV4.self
        ]
    }
    static var stages: [MigrationStage] {
        [
            migrateV1toV2,
            migrateV2toV3,
            migrateV3toV4
        ]
    }
    
    static let migrateV1toV2 = MigrationStage.lightweight(fromVersion: JobSchemaV1.self, toVersion: JobSchemaV2.self)
    
    static let migrateV2toV3 = MigrationStage.custom(
        fromVersion: JobSchemaV2.self,
        toVersion: JobSchemaV3.self,
        willMigrate: nil
    ) { context in
        let jobs = try? context.fetch(FetchDescriptor<JobSchemaV3.Job>())
        jobs?.forEach { job in
            job.newEventSummaries = job.eventSummaries.map { EventSummary(eventId: $0.key, summary: $0.value) }
        }
        try? context.save()
    }
    
    static var v3Jobs: [JobSchemaV3.Job] = []
    static let migrateV3toV4 = MigrationStage.custom(
        fromVersion: JobSchemaV3.self,
        toVersion: JobSchemaV4.self,
        willMigrate: { context in
            v3Jobs = (try? context.fetch(FetchDescriptor<JobSchemaV3.Job>())) ?? []
        },
        didMigrate: { context in
            let v4Jobs = try? context.fetch(FetchDescriptor<JobSchemaV4.Job>())
            v4Jobs?.forEach { v4Job in
                guard let v3Job = v3Jobs.first(where: { $0.id == v4Job.id }) else { return }
                v4Job.salaryType = v3Job.isDailyWage ? .daily : .hourly
                v4Job.breaks = [
                    JobBreak(
                        isActive: v3Job.isBreak1,
                        intervalMinutes: v3Job.break1.breakIntervalMinutes,
                        breakMinutes: v3Job.break2.breakMinutes
                    ),
                    JobBreak(
                        isActive: v3Job.isBreak2,
                        intervalMinutes: v3Job.break2.breakIntervalMinutes,
                        breakMinutes: v3Job.break2.breakMinutes
                    )
                ]
                v4Job.wages = v3Job.wages.map { wage in
                    return JobWage(
                        start: wage.start,
                        wage: v3Job.isDailyWage ? wage.dailyWage : wage.hourlyWage
                    )
                }
                v4Job.salary = JobSalary(
                    cutOffDay: v3Job.salaryCutoffDay,
                    paymentDay: v3Job.salaryPaymentDay,
                    paymentType: .nextMonth,
                    histories: v3Job.salaryHistories.map { history in
                        return JobSalary.History(
                            salary: history.salary,
                            year: history.year,
                            month: history.month
                        )
                    }
                )
                v4Job.eventSummaries = v3Job.newEventSummaries.map { eventSummary in
                    return JobEventSummary(
                        eventId: eventSummary.eventId,
                        summary: eventSummary.summary,
                        adjustment: eventSummary.adjustment
                    )
                }
            }
            try? context.save()
        }
    )
}
