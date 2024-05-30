import SwiftData
import SwiftUI

struct OTJobRowView: View {
    let otJob: OneTimeJob
    var body: some View {
        HStack(alignment: .center) {
            Rectangle()
                .frame(width: 4, height: 32)
                .cornerRadius(2)
                .foregroundStyle(.secondary)
            Text(otJob.name)
                .bold()
                .lineLimit(1)
            Spacer()
            Text("\(otJob.salary)円")
                .lineLimit(2)
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
    }
}
