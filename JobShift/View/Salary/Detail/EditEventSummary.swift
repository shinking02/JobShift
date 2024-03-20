import Foundation
import SwiftUI
import SwiftData

struct EditEventSummary: View {
    let eventId: String
    let title: String
    var targetJob: Job
    @State private var summary = ""
    var body: some View {
        List {
            Section(header: Text("メモ")) {
                TextField("", text: $summary)
            }
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            summary = targetJob.eventSummaries[eventId] ?? ""
        }
        .onDisappear {
            targetJob.eventSummaries[eventId] = summary
        }
    }
}
