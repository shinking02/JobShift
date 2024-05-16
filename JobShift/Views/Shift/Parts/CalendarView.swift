import RealmSwift
import SwiftData
import SwiftUI

struct CalendarView: UIViewRepresentable {
    let didSelectDate: (_ dateComponents: DateComponents) -> Void
    @Query(sort: \Job.order) var jobs: [Job]
    @Query var otJobs: [OneTimeJob]

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self, didSelectDate: didSelectDate)
    }
    
    func makeUIView(context: Context) -> some UICalendarView {
        let selection = UICalendarSelectionSingleDate(delegate: context.coordinator)
        let calendarView = UICalendarView()
        calendarView.selectionBehavior = selection
        calendarView.delegate = context.coordinator
        calendarView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        calendarView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return calendarView
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        let monthComponents = uiView.visibleDateComponents
        for day in 1...31 {
            let components = DateComponents(year: monthComponents.year, month: monthComponents.month, day: day)
            uiView.reloadDecorations(forDateComponents: [components], animated: true)
        }
    }

    class Coordinator: NSObject, UICalendarViewDelegate, UICalendarSelectionSingleDateDelegate {
        private let parent: CalendarView
        private let didSelectDate: (_ dateComponents: DateComponents) -> Void
        @ObservedResults(Event.self, sortDescriptor: SortDescriptor(keyPath: "start")) private var events
        
        init(
            parent: CalendarView,
            didSelectDate: @escaping (_ dateComponents: DateComponents) -> Void
        ) {
            self.parent = parent
            self.didSelectDate = didSelectDate
        }

        func calendarView(_ calendarView: UICalendarView, decorationFor dateComponents: DateComponents) -> UICalendarView.Decoration? {
            let dateEvents = getDateEvents(dateComponents)
            let dateOTJobs = parent.otJobs.filter { $0.date.isSameDay(dateComponents.date ?? Date()) }
            let dayJob = parent.jobs.first(where: { job in
                dateEvents.contains(where: { event in
                    event.summary == job.name
                })
            })
            let paymentDayJob = parent.jobs.first(where: { job in
                let paymentDay = job.getPaymentDay(year: dateComponents.year ?? 0, month: dateComponents.month ?? 0)
                return paymentDay.isSameDay(dateComponents.date ?? Date())
            })
            // ここから先は仮実装
            if let dayJob = dayJob {
                return .default(color: UIColor(dayJob.color.toColor()))
            }
            return nil
        }
        
        func dateSelection(_ selection: UICalendarSelectionSingleDate, didSelectDate dateComponents: DateComponents?) {
            guard let dateComponents = dateComponents else {
                return
            }
            didSelectDate(dateComponents)
        }
        
        private func getDateEvents(_ dateComponents: DateComponents) -> Results<Event> {
            if CalendarManager.shared.isShowOnlyJobEvent {
                return events.where({
                    $0.start <= dateComponents.date?.endOfDay ?? Date() &&
                    $0.end > dateComponents.date?.fixed(hour: 9, minute: 0) ?? Date() &&
                    $0.summary.in(parent.jobs.map { $0.name })
                })
            } else {
                return events.where({
                    $0.start <= dateComponents.date?.endOfDay ?? Date() &&
                    $0.end > dateComponents.date?.fixed(hour: 9, minute: 0) ?? Date()
                })
            }
        }
    }
    
}
