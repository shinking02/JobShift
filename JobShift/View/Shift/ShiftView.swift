import Foundation
import SwiftUI

struct ShiftView: View {
    var body: some View {
        NavigationView {
            List {
                CalendarView { dateComponents in
                    let events = EventStore.shared.getEventsFromDate(dateComponents: dateComponents)
                    events.forEach { e in
                        print(e.summary)
                    }
                }
            }
            .navigationTitle("シフト")
        }
    }
}

struct ShiftView_Previews: PreviewProvider {
    static var previews: some View {
        ShiftView()
    }
}
