import RealmSwift
import SwiftData
import SwiftUI

struct ShiftSheetView: View {
    @Binding var selectedDate: Date
    @Query(sort: \Job.order) private var jobs: [Job]
    @Query private var otJobs: [OneTimeJob]
    @ObservedResults(Event.self, sortDescriptor: SortDescriptor(keyPath: "start")) private var events
    @State private var selectedEvent: Event?
    @State private var selectedOtJob: OneTimeJob?
    @State private var showOTJobAddSheet = false
    @State private var showOTJobEditSheet = false
    @State private var showAddEventSheet = false
    @State private var suggestedEvents: [SuggestEvent] = []
    @State private var selectedSuggestEvent: SuggestEvent?
    
    private var dateEvents: Results<Event> {
        let activeCalendarIds = CalendarManager.shared.calendars.filter { $0.isActive }.map { $0.id }
        if CalendarManager.shared.isShowOnlyJobEvent {
            return events.where({
                $0.start <= selectedDate.endOfDay &&
                $0.end > selectedDate.startOfDay &&
                $0.summary.in(jobs.map { $0.name }) &&
                $0.calendarId.in(activeCalendarIds)
            })
        } else {
            return events.where({
                $0.start <= selectedDate.endOfDay &&
                $0.end > selectedDate.startOfDay &&
                $0.calendarId.in(activeCalendarIds)
            })
        }
    }
    private var dateOtJobs: [OneTimeJob] {
        otJobs.filter { $0.date.isSameDay(selectedDate) }
    }
    private var paymentDayJobs: [Job] {
        jobs.filter { job in
            let paymentDay = job.getPaymentDay(year: selectedDate.year, month: selectedDate.month)
            return paymentDay.isSameDay(selectedDate)
        }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                ForEach(dateEvents) { event in
                    Group {
                        Divider()
                        EventRowView(event: event, selectedDate: selectedDate)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                selectedEvent = event
                            }
                    }
                    .padding(.horizontal)
                }
                ForEach(dateOtJobs) { otJob in
                    Group {
                        OTJobRowView(otJob: otJob)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                selectedOtJob = otJob
                            }
                    }
                    .padding(.horizontal)
                }
                ForEach(paymentDayJobs) { job in
                    Group {
                        Divider()
                        PaymentDayRowView(job: job)
                    }
                    .padding(.horizontal)
                }
                if dateEvents.isEmpty && dateOtJobs.isEmpty && paymentDayJobs.isEmpty && suggestedEvents.isEmpty{
                    Divider()
                    Text("予定がありません")
                        .bold()
                        .frame(maxWidth: .infinity, alignment: .center)
                        .frame(height: 33)
                    
                }
                if !suggestedEvents.isEmpty {
                    Text("提案されたイベント")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding([.horizontal, .top])
                        .foregroundStyle(.secondary)
                        .font(.caption)
                    ForEach(Array(suggestedEvents.enumerated()), id: \.element) { index, event in
                        Group {
                            Divider()
                            SuggestEventRowView(job: event.job, start: event.start, end: event.end, isAllDay: event.isAllDay, index: index)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    selectedSuggestEvent = event
                                }
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .refreshable {
                await CalendarManager.shared.syncGoogleCalendar(skipSyncCalendarList: true)
            }
            .frame(maxWidth: .infinity)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Text("\(selectedDate.toString(.weekday))")
                        .font(.title3.bold())
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(
                        action: {
                            showOTJobAddSheet = true
                        },
                        label: {
                            Image("custom.pencil.and.list.clipboard.badge.plus")
                        }
                    )
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(
                        action: {
                            showAddEventSheet = true
                        },
                        label: {
                            Image(systemName: "plus")
                        }
                    )
                    .disabled(jobs.isEmpty)
                }
            }
        }
        .onChange(of: selectedDate) {
            suggestedEvents = getSuggestEvents(selectedDate)
        }
        .onAppear {
            if Storage.getIsDisableEventSuggest() {
                suggestedEvents = []
            } else {
                suggestedEvents = getSuggestEvents(selectedDate)
            }
        }
        .sheet(item: $selectedOtJob) { otJob in
            NavigationStack {
                OTJobEditView(otJob: otJob)
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button("完了") {
                                selectedOtJob = nil
                            }
                        }
                    }
            }
        }
        .sheet(isPresented: $showOTJobAddSheet) {
            OTJobAddView(otJob: OneTimeJob(date: selectedDate))
        }
        .sheet(item: $selectedEvent) { event in
            EventEditView(eventId: event.id, beforeCalendarId: event.calendarId, summary: event.summary, start: event.start, end: event.end, isAllDay: event.isAllDay)
        }
        .sheet(isPresented: $showAddEventSheet) {
            let startDate = Date().fixed(year: selectedDate.year, month: selectedDate.month, day: selectedDate.day)
            EventAddView(selectedJob: jobs.first!, start: startDate, end: startDate.added(hour: 2), isAllDay: false)
        }
        .sheet(item: $selectedSuggestEvent) { event in
            EventAddView(selectedJob: event.job, start: event.start, end: event.end, isAllDay: event.isAllDay)
        }
    }
    
    private struct SuggestEvent: Identifiable, Hashable {
        let id = UUID()
        var job: Job
        var start: Date
        var end: Date
        var isAllDay: Bool
    }
    
    private func getSuggestEvents(_ date: Date) -> [SuggestEvent] {
        if Storage.getIsDisableEventSuggest() {
            return []
        }
        let passedDate = date.added(day: Storage.getEventSuggestIntervalWeek() == 0 ? -21 : Storage.getEventSuggestIntervalWeek() * -7)
        let realm = try! Realm()
        let jobNames = jobs.map { $0.name }
        let events = realm.objects(Event.self)
            .filter("start >= %@ AND start <= %@ AND summary IN %@", passedDate, date, jobNames)
        
        var suggestEvents: [SuggestEvent] = []
        
        for event in events {
            guard let matchingJob = jobs.first(where: { $0.name == event.summary }) else {
                continue
            }
            
            let calendar = Calendar.current
            var newStartComponents = calendar.dateComponents([.year, .month, .day], from: date)
            newStartComponents.hour = calendar.component(.hour, from: event.start)
            newStartComponents.minute = calendar.component(.minute, from: event.start)
            let newStart = calendar.date(from: newStartComponents)!
            
            let duration = event.end.timeIntervalSince(event.start)
            let newEnd = newStart.addingTimeInterval(duration)
            
            let suggestEvent = SuggestEvent(job: matchingJob, start: newStart, end: newEnd, isAllDay: event.isAllDay)
            
            if !suggestEvents.contains(where: { $0.job == matchingJob && $0.start == newStart && $0.end == newEnd && $0.isAllDay == event.isAllDay }) {
                suggestEvents.append(suggestEvent)
            }
        }
        return suggestEvents
    }

}
