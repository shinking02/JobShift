import SwiftUI
import GoogleAPIClientForREST

struct CalendarView: UIViewRepresentable {
    @ObservedObject var eventStore: EventStore
    @Binding var dateSelected: DateComponents?
    @Binding var dateEvents: [GTLRCalendar_Event]

    func makeUIView(context: Context) -> some UICalendarView {
        let view = UICalendarView()
        view.delegate = context.coordinator
        view.calendar = Calendar(identifier: .gregorian)
        view.delegate = context.coordinator
        view.locale = Locale(identifier: "ja_JP")
        view.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        view.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        let dateSelection = UICalendarSelectionSingleDate(delegate: context.coordinator)
        view.selectionBehavior = dateSelection
        return view
    }
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self, eventStore: _eventStore)
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        if let dateSelected = dateSelected {
            withAnimation {
                dateEvents = EventManager.getEventsFromDate(events: eventStore.events, dateComponents: dateSelected)
            }
        }
        let calendar = Calendar(identifier: .gregorian)
        let startDate = calendar.date(from: uiView.visibleDateComponents)!
        let endDate = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: startDate)!
        var dateComponentsArray: [DateComponents] = []
        var currentDate = startDate
        while currentDate <= endDate {
            let components = calendar.dateComponents([.year, .month, .day], from: currentDate)
            dateComponentsArray.append(components)
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
        }
        uiView.reloadDecorations(forDateComponents: dateComponentsArray, animated: true)
    }
    
    class Coordinator: NSObject, UICalendarViewDelegate, UICalendarSelectionSingleDateDelegate {
        var parent: CalendarView
        @ObservedObject var eventStore: EventStore
        init(parent: CalendarView, eventStore: ObservedObject<EventStore>) {
            self.parent = parent
            self._eventStore = eventStore
        }
        
        @MainActor
        func calendarView(_ calendarView: UICalendarView, decorationFor dateComponents: DateComponents) -> UICalendarView.Decoration? {
            let foundEvents = EventManager.getEventsFromDate(events: eventStore.events, dateComponents: dateComponents)
            if foundEvents.isEmpty { return nil }
            return .default(color: UIColor(Color.secondary))
        }
        
        func dateSelection(_ selection: UICalendarSelectionSingleDate, didSelectDate dateComponents: DateComponents?) {
            parent.dateSelected = dateComponents
            guard let dateComponents else { return }
            parent.dateEvents = EventManager.getEventsFromDate(events: eventStore.events, dateComponents: dateComponents)
        }
    }
}
