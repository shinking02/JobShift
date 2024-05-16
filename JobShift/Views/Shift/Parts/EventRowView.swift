import SwiftData
import SwiftUI

struct EventRowView: View {
    let event: Event
    let selectedDate: Date
    @Query private var jobs: [Job]
    private var color: Color {
        jobs.first(where: { $0.name == event.summary })?.color.toColor() ?? .secondary
    }
    private var detail: String {
        let start = event.start.isSameDay(selectedDate) ? event.start.toString(.time) : nil
        let end = event.end.isSameDay(selectedDate) ? event.end.toString(.time) : nil
        if event.isAllDay || (start == nil && end == nil) {
            return "終日"
        }
        return "\(start ?? "終了")\n\(end ?? "")"
    }
    var body: some View {
        HStack(alignment: .center) {
            Rectangle()
                .frame(width: 4, height: 32)
                .cornerRadius(2)
                .foregroundStyle(color)
            Text(event.summary)
                .bold()
                .lineLimit(1)
            Spacer()
            Text(detail)
                .lineLimit(2)
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
    }
}
