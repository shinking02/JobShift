import Foundation
import SwiftUI
import GoogleAPIClientForREST

struct EventRow: View {
    let event: GTLRCalendar_Event
    var body: some View {
        HStack {
            Text(event.summary ?? "")
            Spacer()
        }
    }
}
