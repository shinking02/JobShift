import RealmSwift
import SwiftUI

struct CalendarView: UIViewRepresentable {
    let didSelectDate: (_ dateComponents: DateComponents) -> Void
    var jobs: [Job]
    var otJobs: [OneTimeJob]
    var isShowOnlyJobEvent: Bool
    var activeCalendars: [UserCalendar]

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
        context.coordinator.parent = self
        context.coordinator.observeChanges(in: uiView)
        DispatchQueue.main.async {
            let components = (1...31).compactMap { day -> DateComponents? in
                guard let year = uiView.visibleDateComponents.year, let month = uiView.visibleDateComponents.month else { return nil }
                return DateComponents(year: year, month: month, day: day)
            }
            uiView.reloadDecorations(forDateComponents: components, animated: true)
        }
        
        if context.coordinator.reloadWorkItem != nil {
            DispatchQueue.main.async {
                context.coordinator.clearAllCaches()
                context.coordinator.reloadCalendarDecorations(in: uiView)
            }
        }
    }

    class Coordinator: NSObject, UICalendarViewDelegate, UICalendarSelectionSingleDateDelegate {
        var parent: CalendarView
        var realm: Realm
        var notificationToken: NotificationToken?
        var reloadWorkItem: DispatchWorkItem?
        
        private var lastIsShowOnlyJobEvent: Bool
        private var eventCache = [DateComponents: Results<Event>]()
        private var decorationCache = [DateComponents: UICalendarView.Decoration?]()

        init(parent: CalendarView, didSelectDate: @escaping (_ dateComponents: DateComponents) -> Void) {
            self.parent = parent
            self.realm = try! Realm()
            self.lastIsShowOnlyJobEvent = parent.isShowOnlyJobEvent
        }

        deinit {
            notificationToken?.invalidate()
        }

        func observeChanges(in uiView: UICalendarView) {
            guard let year = uiView.visibleDateComponents.year, let month = uiView.visibleDateComponents.month else { return }

            let startOfMonth = Calendar.current.date(from: DateComponents(year: year, month: month, day: 1))!
            let endOfMonth = Calendar.current.date(from: DateComponents(year: year, month: month + 1, day: 0))!

            let events = realm.objects(Event.self).filter("start >= %@ AND end <= %@", startOfMonth as NSDate, endOfMonth as NSDate)
            notificationToken = events.observe { [weak self] changes in
                switch changes {
                case .update:
                    self?.clearAllCaches()
                    self?.reloadCalendarDecorations(in: uiView)
                case .error(let error):
                    print("Error observing Realm changes: \(error)")
                default:
                    break
                }
            }
        }

        func clearAllCaches() {
            eventCache.removeAll()
            decorationCache.removeAll()
        }

        func reloadCalendarDecorations(in uiView: UICalendarView) {
            reloadWorkItem?.cancel()
            reloadWorkItem = DispatchWorkItem {
                DispatchQueue.main.async {
                    let components = (1...31).compactMap { day -> DateComponents? in
                        guard let year = uiView.visibleDateComponents.year, let month = uiView.visibleDateComponents.month else { return nil }
                        return DateComponents(year: year, month: month, day: day)
                    }
                    uiView.reloadDecorations(forDateComponents: components, animated: true)
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: reloadWorkItem!)
        }

        func calendarView(_ calendarView: UICalendarView, decorationFor dateComponents: DateComponents) -> UICalendarView.Decoration? {
            if lastIsShowOnlyJobEvent != parent.isShowOnlyJobEvent {
                clearAllCaches()
                reloadCalendarDecorations(in: calendarView)
                lastIsShowOnlyJobEvent = parent.isShowOnlyJobEvent
            }
            if let cachedDecoration = decorationCache[dateComponents] {
                return cachedDecoration
            }

            let decoration = calculateDecoration(dateComponents: dateComponents)
            decorationCache[dateComponents] = decoration
            return decoration
        }

        func dateSelection(_ selection: UICalendarSelectionSingleDate, didSelectDate dateComponents: DateComponents?) {
            guard let dateComponents = dateComponents else { return }
            parent.didSelectDate(dateComponents)
        }

        private func calculateDecoration(dateComponents: DateComponents) -> UICalendarView.Decoration? {
            let dateEvents = getDateEvents(dateComponents)
            let dayOTJobs = parent.otJobs.filter { $0.date.isSameDay(dateComponents.date ?? Date()) }
            let dayJob = parent.jobs.first { job in dateEvents.contains { $0.summary == job.name } }
            let paymentDayJob = parent.jobs.first { $0.getPaymentDay(year: dateComponents.year ?? 0, month: dateComponents.month ?? 0).isSameDay(dateComponents.date ?? Date()) && $0.displayPaymentDay }

            if let paymentDayJob = paymentDayJob {
                return createCustomDecoration(dayJob: dayJob, dayOTJobs: dayOTJobs, paymentDayJob: paymentDayJob, dateEvents: dateEvents)
            }
            if let dayJob = dayJob {
                return .default(color: UIColor(dayJob.color.toColor()))
            }
            return !dayOTJobs.isEmpty || !dateEvents.isEmpty ? .default(color: UIColor(.secondary)) : nil
        }

        private func createCustomDecoration(dayJob: Job?, dayOTJobs: [OneTimeJob], paymentDayJob: Job, dateEvents: Results<Event>) -> UICalendarView.Decoration {
            if let dayJob = dayJob {
                return .image(
                    UIImage(named: "custom.yensign.badge", in: nil, with: UIImage.SymbolConfiguration(paletteColors: [UIColor(dayJob.color.toColor()), UIColor(paymentDayJob.color.toColor())])), size: .large
                )
            }
            if !dayOTJobs.isEmpty || (!dateEvents.isEmpty && !parent.isShowOnlyJobEvent) {
                return .image(
                    UIImage(named: "custom.yensign.badge", in: nil, with: UIImage.SymbolConfiguration(paletteColors: [UIColor(.secondary), UIColor(paymentDayJob.color.toColor())])), size: .large
                )
            }
            return .image(UIImage(systemName: "yensign"), color: UIColor(paymentDayJob.color.toColor()), size: .large)
        }

        private func getDateEvents(_ dateComponents: DateComponents) -> Results<Event> {
            if let cachedEvents = eventCache[dateComponents] {
                return cachedEvents
            }

            let activeCalendarIds = parent.activeCalendars.map { $0.id }
            let date = dateComponents.date?.fixed(hour: 9, minute: 0) ?? Date()
            let startOfDay = date.startOfDay
            let endOfDay = date.endOfDay

            let predicate: NSPredicate = createPredicate(startOfDay: startOfDay, endOfDay: endOfDay, date: date, activeCalendarIds: activeCalendarIds)

            let events = realm.objects(Event.self).filter(predicate)
            eventCache[dateComponents] = events
            return events
        }

        private func createPredicate(startOfDay: Date, endOfDay: Date, date: Date, activeCalendarIds: [String]) -> NSPredicate {
            if parent.isShowOnlyJobEvent {
                return NSPredicate(format: "(start <= %@ AND end > %@ AND calendarId IN %@ AND summary IN %@) OR (start >= %@ AND end <= %@ AND start <= %@ AND calendarId IN %@ AND summary IN %@)",
                    endOfDay as NSDate, date as NSDate, activeCalendarIds, parent.jobs.map { $0.name }, startOfDay as NSDate, date as NSDate, date as NSDate, activeCalendarIds, parent.jobs.map { $0.name })
            } else {
                return NSPredicate(format: "(start <= %@ AND end > %@ AND calendarId IN %@) OR (start >= %@ AND end <= %@ AND start <= %@ AND calendarId IN %@)",
                    endOfDay as NSDate, date as NSDate, activeCalendarIds, startOfDay as NSDate, date as NSDate, date as NSDate, activeCalendarIds)
            }
        }
    }
}
