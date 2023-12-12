import SwiftUI

struct CalendarView: UIViewRepresentable {
    let didSelectDate: (_ dateComponents: DateComponents) -> Void
    
    final public class Coordinator: NSObject, UICalendarSelectionSingleDateDelegate, UICalendarViewDelegate {
        let didSelectDate: (_ dateComponents: DateComponents) -> Void
        
        init(
            didSelectDate: @escaping (_ dateComponents: DateComponents) -> Void
        ) {
            self.didSelectDate = didSelectDate
        }
        
        public func dateSelection(_ selection: UICalendarSelectionSingleDate, didSelectDate dateComponents: DateComponents?) {
            guard let dateComponents = dateComponents else {
                return
            }
            didSelectDate(dateComponents)
        }
        
        public func calendarView(_ calendarView: UICalendarView, decorationFor dateComponents: DateComponents) -> UICalendarView.Decoration? {
            let dateEvents = EventStore.shared.getEventsFromDate(dateComponents: dateComponents)
            // FIXME: Job対応
            if dateEvents.isEmpty {
                return nil
            } else {
                return .default(color: UIColor(Color.secondary))
            }
        }
    }
    
    
    public func makeCoordinator() -> Coordinator {
        Coordinator(didSelectDate: didSelectDate)
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
