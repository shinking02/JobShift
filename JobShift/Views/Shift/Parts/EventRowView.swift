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
        if event.start.isSameDay(selectedDate) && event.end.isSameDay(selectedDate) {
            if event.isAllDay {
                return "終日"
            }
            return "\(event.start.toString(.time))\n\(event.end.toString(.time))"
        }
        if event.isAllDay {
            return "\(event.start.toString(.normal))\n\(event.end.toString(.normal))"
        }
        return "\(event.start.toString(.dateTime))\n\(event.end.toString(.dateTime))"
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
