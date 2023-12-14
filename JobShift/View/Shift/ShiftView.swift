import Foundation
import SwiftUI
import GoogleAPIClientForREST

struct ShiftView: View {
    @State private var dateEvents: [GTLRCalendar_Event]?
    @State private var selectedDate: DateComponents
    @EnvironmentObject var eventStore: EventStore
    init() {
        let currentDate = Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: currentDate)
        self._selectedDate = State(initialValue: components)
    }
    var body: some View {
        NavigationView {
            List {
                CalendarView(eventStore: eventStore) { dateComponents in
                    dateEvents = eventStore.getEventsFromDate(dateComponents: dateComponents)
                    selectedDate = dateComponents
                }
                if let dateEvents = dateEvents {
                    ForEach(dateEvents, id: \.identifier) { event in
                        EventRow(event: event)
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
            self.dateEvents = eventStore.getEventsFromDate(dateComponents: selectedDate)
        }
    }
}
