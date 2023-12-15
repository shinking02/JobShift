import Foundation
import SwiftUI
import GoogleAPIClientForREST

struct ShiftView: View {
    @EnvironmentObject var eventStore: EventStore
    @State private var dateEvents: [GTLRCalendar_Event] = []
    @State private var dateSelected: DateComponents?
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
    }
}
