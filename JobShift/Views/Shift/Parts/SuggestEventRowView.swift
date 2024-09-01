import SwiftUI

struct SuggestEventRowView: View {
    var job: Job
    var start: Date
    var end: Date
    var isAllDay: Bool
    var index: Int
    
    @State private var appear: Bool = false
    
    var body: some View {
        HStack(alignment: .center) {
            Rectangle()
                .frame(width: 4, height: 32)
                .cornerRadius(2)
                .foregroundStyle(job.color.toColor())
            Image(systemName: "brain.filled.head.profile")
                .symbolEffect(.bounce.up.byLayer, value: appear)
                .foregroundStyle(
                    LinearGradient(colors: [.orange, .pink, .purple, .blue], startPoint: .topLeading, endPoint: .bottomTrailing)
                )
            Text(job.name)
                .bold()
                .lineLimit(1)
            Spacer()
            if appear {
                Text(isAllDay ? "終日" : "\(start.toString(.time))\n\(end.toString(.time))")
                    .lineLimit(2)
                    .font(.caption)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(
                        LinearGradient(colors: [.orange, .pink, .purple, .blue], startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
            }
        }
        .onAppear {
            Task {
                try await Task.sleep(millisecond: 120 + Double(index) * 50)
                withAnimation {
                    appear = true
                }
            }
        }
    }
}
