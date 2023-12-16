import Foundation
import GoogleAPIClientForREST

struct EventManager {
    static func getEventsFromDate(events: [GTLRCalendar_Event], dateComponents: DateComponents) -> [GTLRCalendar_Event] {
        guard let targetStartDate = Calendar.current.date(from: dateComponents),
              let targetEndDate = Calendar.current.date(byAdding: .day, value: 1, to: targetStartDate) else {
            return []
        }
        let startIndex = binarySearch(events, targetStartDate, { $0.start?.dateTime?.date ?? $0.start?.date?.date ?? Date.distantFuture })
        let filteredEvents = events[startIndex..<events.endIndex].prefix { event in
            let startDate = event.start?.dateTime?.date ?? event.start?.date?.date
            let endDate = event.end?.dateTime?.date ?? event.end?.date?.date
            if let startDate = startDate, let endDate = endDate {
                return startDate < targetEndDate && endDate > targetStartDate
            }
            return false
        }
        // FIXME: 日付を跨いだ終日イベント, 日付を跨いだ半日以上のイベントは返却(暫定対応: 10個前のイベントまで確認)
        let additionalEvents: [GTLRCalendar_Event] = {
            let pastStartIndex = startIndex < 10 ? 0 : startIndex - 10
            return events[pastStartIndex..<startIndex].filter { event in
                if let startDate = event.start?.dateTime?.date, let endDate = event.end?.dateTime?.date,
                   let targetHarfDate = Calendar.current.date(byAdding: .hour, value: -12, to: targetEndDate) {
                    return startDate..<endDate ~= targetHarfDate
                } else if let startDate = event.start?.date?.date, let endDate = event.end?.date?.date {
                    return startDate...endDate ~= targetEndDate
                }
                return false
            }
        }()
        
        return Array(additionalEvents + filteredEvents)
    }
    
    static private func binarySearch<T>(_ array: [T], _ target: Date, _ key: (T) -> Date) -> Array<T>.Index {
        var low = array.startIndex
        var high = array.endIndex
        while low < high {
            let mid = low + (high - low) / 2
            if key(array[mid]) < target {
                low = mid + 1
            } else {
                high = mid
            }
        }
        return low
    }
}
