import Foundation
import SwiftUI
import SwiftData

struct ShiftView: View {
    @EnvironmentObject var eventStore: EventStore
    @Query private var jobs: [Job]
    @State private var dateEvents: [Event] = []
    @State private var dateSelected: DateComponents?
    @State private var showEventEditView = false
    init() {
        let currentDate = Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: currentDate)
        self._dateSelected = State(initialValue: components)
    }
    var body: some View {
        NavigationView {
            List {
                CalendarView(eventStore: eventStore, dateSelected: $dateSelected, dateEvents: $dateEvents)
                ForEach(dateEvents, id: \.self) { event in
                    EventRow(dateComponents: dateSelected!, event: event)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            self.showEventEditView = true
                            print(event)
                        }
                        .sheet(isPresented: $showEventEditView) {
                            EmptyView()
                        }
                }
                HStack {
                    Spacer()
                    Button(action: {
                        
                    }, label: {
                        Text("追加")
                    }).disabled(true)
                    Spacer()
                }
            }
            .navigationTitle("シフト")
        }
        .onAppear {
            if UserDefaults.standard.bool(forKey: UserDefaultsKeys.showJobOnly) {
                eventStore.deleteNormalEvents(jobs: jobs)
            }
        }
    }
}
