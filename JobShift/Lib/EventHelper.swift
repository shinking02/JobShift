import Foundation
import SwiftUI
import SwiftData

struct EventHelper {
    private let dataSource = SwiftDataSource.shared
    private let calendar = Calendar.current
    
    func getEventColor(_ event: Event) -> Color {
        let jobs = dataSource.fetchJobs()
        let job = jobs.first { $0.name == event.summary }
        if let job = job {
            return job.color.getColor()
        }
        return .secondary
    }
    
    func getIntervalText(_ event: Event, _ date: Date) -> (String, String?) {
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        if event.isAllDay || event.start <= startOfDay && endOfDay <= event.end {
            return ("終日", nil)
        }
        if event.start < startOfDay {
            return ("〜" + event.end.toHmmString(), nil)
        }
        if endOfDay < event.end {
            return (event.start.toHmmString() + "〜", nil)
        }
        return (event.start.toHmmString(), event.end.toHmmString())
    }
}
