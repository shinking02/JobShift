import SwiftData
import SwiftUI

struct PaymentDayRowView: View {
    let job: Job
    var body: some View {
        HStack(alignment: .center) {
            Rectangle()
                .frame(width: 4, height: 32)
                .cornerRadius(2)
                .foregroundStyle(job.color.toColor())
            Text("\(job.name)給料日")
                .bold()
                .lineLimit(1)
            Spacer()
            Text("130000円")
                .lineLimit(2)
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
    }
}
