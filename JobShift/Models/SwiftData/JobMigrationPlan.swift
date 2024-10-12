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

    static let migrateV3toV4 = MigrationStage.custom(
        fromVersion: JobSchemaV3.self,
        toVersion: JobSchemaV4.self,
        willMigrate: nil) { context in
            
        }
}
