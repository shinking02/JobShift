import RealmSwift
import SwiftData
import SwiftUI

struct ShiftSheetView: View {
    @Binding var selectedDate: Date
    @Query private var otJobs: [OneTimeJob]
    @ObservedResults(Event.self, sortDescriptor: SortDescriptor(keyPath: "start")) private var events
    @State private var selectedEvent: Event?
    @State private var selectedOtJob: OneTimeJob?
    @State private var showOTJobAddSheet = false
    @State private var showOTJobEditSheet = false
    
    
    private var dateEvents: Results<Event> {
        events.where({ $0.start <= selectedDate.endOfDay && $0.end > selectedDate.startOfDay })
    }
    private var dateOtJobs: [OneTimeJob] {
        otJobs.filter { $0.date.isSameDay(selectedDate) }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                ForEach(dateEvents) { event in
                    Group {
                        Divider()
                        EventRowView(event: event, selectedDate: selectedDate)
                            .onTapGesture {
                                selectedEvent = event
                            }
                    }
                    .padding(.horizontal)
                }
                if dateEvents.isEmpty && dateOtJobs.isEmpty {
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
                    }
                }
        }
        .sheet(item: $selectedOtJob) { otJob in
            OTJobEditView(otJob: otJob)
        }
        .sheet(isPresented: $showOTJobAddSheet) {
            OTJobAddView(otJob: OneTimeJob(date: selectedDate))
        }
    }
}
