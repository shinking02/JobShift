import RealmSwift
import SwiftData
import SwiftUI

struct CalendarView: UIViewRepresentable {
    let didSelectDate: (_ dateComponents: DateComponents) -> Void
    @Query(sort: \Job.order) private var jobs: [Job]
    @Query private var otJobs: [OneTimeJob]

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
        context.coordinator.decorationCache.removeAll()
        let monthComponents = uiView.visibleDateComponents
        Task {
            let components = (1...31).compactMap { day -> DateComponents? in
                guard let year = monthComponents.year, let month = monthComponents.month else {
                    return nil
                }
                return DateComponents(year: year, month: month, day: day)
            }
            await MainActor.run {
                uiView.reloadDecorations(forDateComponents: components, animated: true)
            }
        }
    }

    class Coordinator: NSObject, UICalendarViewDelegate, UICalendarSelectionSingleDateDelegate {
        private let parent: CalendarView
        private let didSelectDate: (_ dateComponents: DateComponents) -> Void
        // Viewをキャッシュするとエラーになる  https://stackoverflow.com/questions/78517446/uicalendarview-nsinvalidargumentexception-error
        var decorationCache: [DateComponents: DecorationInfo] = [:]
        
        init(
            parent: CalendarView,
            didSelectDate: @escaping (_ dateComponents: DateComponents) -> Void
        ) {
            self.parent = parent
            self.didSelectDate = didSelectDate
        }

        func calendarView(_ calendarView: UICalendarView, decorationFor dateComponents: DateComponents) -> UICalendarView.Decoration? {
            if let decoration = decorationCache[dateComponents] {
                return buildDecoration(info: decoration)
            }
            Task.detached {
                let decoration = self.caluculateDecoration(dateComponents: dateComponents)
                await MainActor.run {
                    self.decorationCache[dateComponents] = decoration
                    calendarView.reloadDecorations(forDateComponents: [dateComponents], animated: false)
                }
            }
            return nil
        }
        
        func dateSelection(_ selection: UICalendarSelectionSingleDate, didSelectDate dateComponents: DateComponents?) {
            guard let dateComponents = dateComponents else {
                return
            }
            didSelectDate(dateComponents)
        }
        
        private func buildDecoration(info: DecorationInfo) -> UICalendarView.Decoration? {
            switch info.type {
            case .none:
                return nil
            case .circle:
                return .default(color: info.primaryColor)
            case .payment:
                return .image(UIImage(systemName: "circle"), color: info.primaryColor)
            case .circlePayment:
                guard let primaryColor = info.primaryColor, let secondaryColor = info.secondaryColor else { return nil }
                return .image(
                    UIImage(
                        systemName: "circle.inset.filled",
                        withConfiguration: UIImage.SymbolConfiguration(paletteColors: [primaryColor, secondaryColor])
                    )
                )
            }
        }
        
        private func caluculateDecoration(dateComponents: DateComponents) -> DecorationInfo {
            let dateEvents = self.getDateEvents(dateComponents)
            let dayOTJobs = self.parent.otJobs.filter { $0.date.isSameDay(dateComponents.date ?? Date()) }
            let dayJob = self.parent.jobs.first(where: { job in
                dateEvents.contains(where: { event in
                    event.summary == job.name
                })
            })
            
            let paymentDayJob = self.parent.jobs.first(where: { job in
                let paymentDay = job.getPaymentDay(year: dateComponents.year ?? 0, month: dateComponents.month ?? 0)
                return paymentDay.isSameDay(dateComponents.date ?? Date())
            })
            // バイト + 給料日
            if let paymentDayJob = paymentDayJob, let dayJob = dayJob {
                return DecorationInfo(type: .circlePayment, primaryColor: UIColor(dayJob.color.toColor()), secondaryColor: UIColor(paymentDayJob.color.toColor()))
            }
            // 単発バイト + 給料日
            if let paymentDayJob = paymentDayJob, !dayOTJobs.isEmpty {
                return DecorationInfo(type: .circlePayment, primaryColor: UIColor(paymentDayJob.color.toColor()), secondaryColor: UIColor(.secondary))
            }
            // 予定 + 給料日
            if let paymentDayJob = paymentDayJob, !dateEvents.isEmpty && !CalendarManager.shared.isShowOnlyJobEvent {
                return DecorationInfo(type: .circlePayment, primaryColor: UIColor(.secondary), secondaryColor: UIColor(paymentDayJob.color.toColor()))
            }
            // 給料日
            if let paymentDayJob = paymentDayJob {
                return DecorationInfo(type: .payment, primaryColor: UIColor(paymentDayJob.color.toColor()))
            }
            // バイト
            if let dayJob = dayJob {
                return DecorationInfo(type: .circle, primaryColor: UIColor(dayJob.color.toColor()))
            }
            // 単発バイト
            if !dayOTJobs.isEmpty {
                return DecorationInfo(type: .circle)
            }
            // 予定
            if !dateEvents.isEmpty && !CalendarManager.shared.isShowOnlyJobEvent {
                return DecorationInfo(type: .circle)
            }
            return DecorationInfo(type: .none)
        }
        
        private func getDateEvents(_ dateComponents: DateComponents) -> Results<Event> {
            // swiftlint:disable:next force_try
            let realm = try! Realm()
            let events = realm.objects(Event.self)
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

struct DecorationInfo: Identifiable {
    enum DecorationType {
        case none
        case circle
        case payment
        case circlePayment
    }
    let id = UUID()
    let type: DecorationType
    var primaryColor: UIColor? = UIColor(.secondary)
    var secondaryColor: UIColor?
}
