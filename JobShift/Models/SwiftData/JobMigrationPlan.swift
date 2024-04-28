import Foundation
import SwiftData

enum JobMigrationPlan: SchemaMigrationPlan {
    static var schemas: [VersionedSchema.Type] {
        [
            JobSchemaV3.self,
            JobSchemaV4.self
        ]
    }
    static var stages: [MigrationStage] {
        [
            migrateV3toV4
        ]
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
//                v4Job.name = v3Job.name
//                v4Job.color = v3Job.color
//                v4Job.startDate = v3Job.startDate
//                v4Job.isDailyWage = v3Job.isDailyWage
//                v4Job.isNightWage = v3Job.isNightWage
//                v4Job.isHolidayWage = v3Job.isHolidayWage
//                v4Job.commuteWage = v3Job.commuteWage
//                v4Job.displayPaymentDay = v3Job.displayPaymentDay
                v4Job.breaks = (
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
                )
                v4Job.wages = v3Job.wages.map { wage in
                    return JobWage(
                        start: wage.start,
                        end: wage.end,
                        hourlyWage: wage.hourlyWage,
                        dailyWage: wage.dailyWage
                    )
                }
                v4Job.salary = JobSalary(
                    cutOffDay: v3Job.salaryCutoffDay,
                    paymentDay: v3Job.salaryPaymentDay,
                    paymentType: .sameMonth,
                    history: v3Job.salaryHistories.map { history in
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
