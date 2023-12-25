import Foundation
import SwiftUI
import SwiftData

struct ShiftView: View {
    @EnvironmentObject var userState: UserState
    @EnvironmentObject var eventStore: EventStore
    @Query private var jobs: [Job]
    @State private var dateEvents: [Event] = []
    @State private var selectedDate: DateComponents?
    @State private var showEventEditView = false
    @State private var showAddEventView = false
    @State private var selectedEvent: Event? = nil
    
    init() {
        self._selectedDate = State(initialValue: Calendar.current.dateComponents([.year, .month, .day], from: Date()))
    }
    var body: some View {
        NavigationView {
            VStack {
                CalendarView(eventStore: eventStore, selectedDate: $selectedDate, dateEvents: $dateEvents)
                    .frame(height: 460)
                    .padding(.horizontal)
                List {
                    ForEach(dateEvents, id: \.id) { event in
                        EventRow(dateComponents: selectedDate!, event: event)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                self.selectedEvent = event
                                self.showEventEditView = true
                            }
                    }
                    .sheet(item: $selectedEvent) { event in
                        EventEditView(event: event)
                    }
                }
                .listStyle(.plain)
            }
            .sheet(isPresented: $showAddEventView) {
                EventAddView(suggestDate: selectedDate!, newEvent: Event(), selectedCal: userState.mainCal!, selectedJob: jobs[0])
            }
            .navigationTitle("シフト")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                Button(action: {
                    self.showAddEventView = true
                }, label: {
                    Image(systemName: "plus")
                })
                .disabled(jobs.count == 0)
            }
        }
        .onAppear {
            if UserDefaults.standard.bool(forKey: UserDefaultsKeys.showJobOnly) {
                eventStore.deleteNormalEvents(jobs: jobs)
            }
        }
    }
}
