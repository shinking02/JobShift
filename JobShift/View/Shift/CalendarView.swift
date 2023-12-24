import SwiftUI
import SwiftData

struct CalendarView: UIViewRepresentable {
    @ObservedObject var eventStore: EventStore
    @Query private var jobs: [Job]
    @Binding var selectedDate: DateComponents?
    @Binding var dateEvents: [Event]

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
        if let selectedDate = selectedDate {
            withAnimation {
                dateEvents = eventStore.getEventsFromDate(dateComponents: selectedDate)
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
            let foundEvents = eventStore.getEventsFromDate(dateComponents: dateComponents)
            if foundEvents.isEmpty { return nil }
            let jobNames = parent.jobs.map { $0.name }
            let jobEvent = foundEvents.first { jobNames.contains($0.gEvent.summary ?? "") }
            guard let jobEvent else { return .default(color: UIColor(Color.secondary)) }
            let job = parent.jobs.first { $0.name == jobEvent.gEvent.summary }
            guard let job else { return .default(color: UIColor(Color.secondary)) }
            return .default(color: UIColor(job.color.getColor()))
        }
        
        func dateSelection(_ selection: UICalendarSelectionSingleDate, didSelectDate dateComponents: DateComponents?) {
            parent.selectedDate = dateComponents
            guard let dateComponents else { return }
            parent.dateEvents = eventStore.getEventsFromDate(dateComponents: dateComponents)
        }
    }
}
