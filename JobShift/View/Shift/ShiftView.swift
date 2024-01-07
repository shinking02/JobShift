import Foundation
import SwiftUI
import SwiftData

struct ShiftView: View {
    @EnvironmentObject var userState: UserState
    @EnvironmentObject var eventStore: EventStore
    @Environment(\.dismiss) var dismiss
    @Query private var jobs: [Job]
    @Query private var otJobs: [OneTimeJob]
    @State private var dateEvents: [Event] = []
    @State private var selectedDate: DateComponents?
    @State private var showAddEventView = false
    @State private var selectedEvent: Event? = nil
    @State private var selectedOTJob: OneTimeJob? = nil
    
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
                    let dateOtJobs = otJobs.filter { otJob in
                        let jobDateComp = Calendar.current.dateComponents([.year, .month, .day], from: otJob.date)
                        return jobDateComp.year == selectedDate!.year && jobDateComp.month == selectedDate!.month && jobDateComp.day == selectedDate!.day
                    }
                    ForEach(dateOtJobs, id: \.self) { otJob in
                        HStack {
                            Image(systemName: "circle.fill")
                                .foregroundColor(.secondary)
                                .font(.caption)
                            Text(otJob.name)
                            Spacer()
                            Text(otJob.summary)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            self.selectedOTJob = otJob
                        }
                    }
                    .sheet(item: $selectedOTJob) { otJob in
                        OTJobEditSheet(otJob: otJob)
                    }
                    ForEach(dateEvents, id: \.id) { event in
                        EventRow(dateComponents: selectedDate!, event: event)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                self.selectedEvent = event
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

struct OTJobEditSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State var otJob: OneTimeJob
    
    var body: some View {
        NavigationView {
            OTJobEditView(editOtJob: otJob)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("完了") {
                            dismiss()
                        }
                    }
                }
        }
    }
}
