import RealmSwift
import SwiftData
import SwiftUI

struct ShiftSheetView: View {
    @Binding var selectedDate: Date
    @Query private var jobs: [Job]
    @Query private var otJobs: [OneTimeJob]
    @ObservedResults(Event.self, sortDescriptor: SortDescriptor(keyPath: "start")) private var events
    @State private var selectedEvent: Event?
    @State private var selectedOtJob: OneTimeJob?
    @State private var showOTJobAddSheet = false
    @State private var showOTJobEditSheet = false
    
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
                        Divider()
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
                if dateEvents.isEmpty && dateOtJobs.isEmpty && paymentDayJobs.isEmpty {
                    Divider()
                    Text("予定がありません")
                        .bold()
                        .frame(maxWidth: .infinity, alignment: .center)
                        .frame(height: 32)
                    
                }
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
                            action: {},
                            label: {
                                Image(systemName: "plus")
                            }
                        )
                        .disabled(true)
                    }
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
    }
}
