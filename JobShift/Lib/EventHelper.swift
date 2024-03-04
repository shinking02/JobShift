import Foundation
import SwiftUI
import SwiftData

struct EventHelper {
    private let dataSource = SwiftDataSource.shared
    
    func getEventColor(_ event: Event) -> Color {
        let jobs = dataSource.fetchJobs()
        let job = jobs.first { $0.name == event.summary }
        if let job = job {
            return job.color.getColor()
        }
        return .secondary
    }
}
