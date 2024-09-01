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
        let monthComponents = uiView.visibleDateComponents
        let components = (1...31).compactMap { day -> DateComponents? in
            guard let year = monthComponents.year, let month = monthComponents.month else {
                return nil
            }
            return DateComponents(year: year, month: month, day: day)
        }
        
        DispatchQueue.main.async {
            uiView.reloadDecorations(forDateComponents: components, animated: true)
        }
    }

    class Coordinator: NSObject, UICalendarViewDelegate, UICalendarSelectionSingleDateDelegate {
        var parent: CalendarView
        var realm: Realm
        var notificationToken: NotificationToken?

        init(parent: CalendarView, didSelectDate: @escaping (_ dateComponents: DateComponents) -> Void) {
            self.parent = parent
            self.realm = try! Realm()
        }

        deinit {
            notificationToken?.invalidate()
        }

        func observeChanges(in uiView: UICalendarView) {
            let events = realm.objects(Event.self)
            notificationToken = events.observe { [weak self] changes in
                guard let self = self else { return }
                switch changes {
                case .initial:
                    break
                case .update(_, _, _, _):
                    self.reloadCalendarDecorations(in: uiView)
                case .error(let error):
                    print("Error observing Realm changes: \(error)")
                }
            }
        }

        private func reloadCalendarDecorations(in uiView: UICalendarView) {
            let monthComponents = uiView.visibleDateComponents
            let components = (1...31).compactMap { day -> DateComponents? in
                guard let year = monthComponents.year, let month = monthComponents.month else {
                    return nil
                }
                return DateComponents(year: year, month: month, day: day)
            }
            DispatchQueue.main.async {
                uiView.reloadDecorations(forDateComponents: components, animated: true)
            }
        }

        func calendarView(_ calendarView: UICalendarView, decorationFor dateComponents: DateComponents) -> UICalendarView.Decoration? {
            return calculateDecoration(dateComponents: dateComponents)
        }

        func dateSelection(_ selection: UICalendarSelectionSingleDate, didSelectDate dateComponents: DateComponents?) {
            guard let dateComponents = dateComponents else { return }
            parent.didSelectDate(dateComponents)
        }

        private func calculateDecoration(dateComponents: DateComponents) -> UICalendarView.Decoration? {
            let dateEvents = getDateEvents(dateComponents)
            let dayOTJobs = parent.otJobs.filter { $0.date.isSameDay(dateComponents.date ?? Date()) }
            let dayJob = parent.jobs.first { job in
                dateEvents.contains { event in event.summary == job.name }
            }
            let paymentDayJob = parent.jobs.first { job in
                let paymentDay = job.getPaymentDay(year: dateComponents.year ?? 0, month: dateComponents.month ?? 0)
                return paymentDay.isSameDay(dateComponents.date ?? Date())
            }

            if let paymentDayJob = paymentDayJob {
                if let dayJob = dayJob {
                    return .image(
                        UIImage(named: "custom.yensign.badge", in: nil, with: UIImage.SymbolConfiguration(paletteColors: [UIColor(dayJob.color.toColor()), UIColor(paymentDayJob.color.toColor())])), size: .large
                    )
                }
                if !dayOTJobs.isEmpty {
                    return .image(
                        UIImage(named: "custom.yensign.badge", in: nil, with: UIImage.SymbolConfiguration(paletteColors: [UIColor(.secondary), UIColor(paymentDayJob.color.toColor())])), size: .large
                    )
                }
                if !dateEvents.isEmpty && !parent.isShowOnlyJobEvent {
                    return .image(
                        UIImage(named: "custom.yensign.badge", in: nil, with: UIImage.SymbolConfiguration(paletteColors: [UIColor(.secondary), UIColor(paymentDayJob.color.toColor())])), size: .large
                    )
                }
                return .image(UIImage(systemName: "yensign"), color: UIColor(paymentDayJob.color.toColor()), size: .large)
            }
            if let dayJob = dayJob {
                return .default(color: UIColor(dayJob.color.toColor()))
            }
            if !dayOTJobs.isEmpty {
                return .default(color: UIColor(.secondary))
            }
            if !dateEvents.isEmpty {
                return .default(color: UIColor(.secondary))
            }
            return nil
        }

        private func getDateEvents(_ dateComponents: DateComponents) -> Results<Event> {
            let activeCalendarIds = parent.activeCalendars.map { $0.id }
            let date = dateComponents.date?.fixed(hour: 9, minute: 0) ?? Date()
            let startOfDay = date.startOfDay
            let endOfDay = date.endOfDay
            
            let predicate: NSPredicate
            if parent.isShowOnlyJobEvent {
                predicate = NSPredicate(
                    format: "(start <= %@ AND end > %@ AND calendarId IN %@ AND summary IN %@) OR " +
                            "(start >= %@ AND end <= %@ AND start <= %@ AND calendarId IN %@ AND summary IN %@)",
                    endOfDay as NSDate,
                    date as NSDate,
                    activeCalendarIds,
                    parent.jobs.map { $0.name },
                    startOfDay as NSDate,
                    date as NSDate,
                    date as NSDate,
                    activeCalendarIds,
                    parent.jobs.map { $0.name }
                )
            } else {
                predicate = NSPredicate(
                    format: "(start <= %@ AND end > %@ AND calendarId IN %@) OR " +
                            "(start >= %@ AND end <= %@ AND start <= %@ AND calendarId IN %@)",
                    endOfDay as NSDate,
                    date as NSDate,
                    activeCalendarIds,
                    startOfDay as NSDate,
                    date as NSDate,
                    date as NSDate,
                    activeCalendarIds
                )
            }

            return realm.objects(Event.self).filter(predicate)
        }

    }
}
