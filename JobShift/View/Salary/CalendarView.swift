import SwiftUI

struct CalendarView: UIViewRepresentable {
    @ObservedObject var eventStore: EventStore
    let didSelectDate: (_ dateComponents: DateComponents) -> Void
    
    final public class Coordinator: NSObject, UICalendarSelectionSingleDateDelegate, UICalendarViewDelegate {
        @ObservedObject var eventStore: EventStore
        let didSelectDate: (_ dateComponents: DateComponents) -> Void
        
        init(
            didSelectDate: @escaping (_ dateComponents: DateComponents) -> Void,
            eventStore: ObservedObject<EventStore>
        ) {
            self.didSelectDate = didSelectDate
            self._eventStore = eventStore
        }
        
        public func dateSelection(_ selection: UICalendarSelectionSingleDate, didSelectDate dateComponents: DateComponents?) {
            guard let dateComponents = dateComponents else {
                return
            }
            didSelectDate(dateComponents)
        }
        
        public func calendarView(_ calendarView: UICalendarView, decorationFor dateComponents: DateComponents) -> UICalendarView.Decoration? {
            let dateEvents = eventStore.getEventsFromDate(dateComponents: dateComponents)
            // FIXME: Job対応
            if dateEvents.isEmpty {
                return nil
            } else {
                return .default(color: UIColor(Color.secondary))
            }
        }
    }
    
    
    public func makeCoordinator() -> Coordinator {
        Coordinator(didSelectDate: didSelectDate, eventStore: _eventStore)
    }
    
    
    func makeUIView(context: Context) -> some UIView {
        let selection = UICalendarSelectionSingleDate(delegate: context.coordinator)
        let calendarView = UICalendarView()
        calendarView.selectionBehavior = selection
        calendarView.delegate = context.coordinator
        calendarView.locale = Locale(identifier: "ja_JP")
        calendarView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return calendarView
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {}
}
