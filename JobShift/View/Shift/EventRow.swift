import Foundation
import SwiftUI
import GoogleAPIClientForREST

struct EventRow: View {
    let dateComponents: DateComponents
    let event: GTLRCalendar_Event
    var body: some View {
        HStack {
            Image(systemName: "circle.fill")
                .foregroundColor(getEventColor(event))
                .font(.caption)
            Text(event.summary ?? "")
            Spacer()
            VStack {
                let (start, end) = getEventTimeString(event)
                Text(start)
                if let end = end {
                    Text(end)
                }
            }
            .font(.caption)
            .foregroundColor(.secondary)
        }
    }
    
    func getEventColor(_ event: GTLRCalendar_Event) -> Color {
        return .secondary
    }
    
    func getEventTimeString(_ event: GTLRCalendar_Event) -> (String, String?) {
        if event.start?.date?.date != nil {
            return ("終日", nil)
        }
        if let startDate = event.start?.dateTime?.date, let endDate = event.end?.dateTime?.date {
            let calendar = Calendar.current
            let startComponent = calendar.dateComponents([.year, .month, .day], from: startDate)
            let endComponent = calendar.dateComponents([.year, .month, .day], from: endDate)
            let showDate = startComponent.day != dateComponents.day || endComponent.day != dateComponents.day
            let start = dateStringFromComponents(date: startDate, showDate: showDate)
            let end = dateStringFromComponents(date: endDate, showDate: showDate)
            return (start, end)
        }
        
        return ("", nil)
    }
    
    func dateStringFromComponents(date: Date, showDate: Bool) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = showDate ? "M月d日 H:mm" : "H:mm"
        return formatter.string(from: date)
    }
}
