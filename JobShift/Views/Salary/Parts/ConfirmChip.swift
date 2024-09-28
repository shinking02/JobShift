import SwiftUI

struct ConfirmChip: View {
    @State var isConfirmed: Bool
    var body: some View {
        Text(isConfirmed ? "確定" : "見込み").font(.caption).lineLimit(1)
            .foregroundColor(isConfirmed ? .green : .orange)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .cornerRadius(40)
            .overlay(
                RoundedRectangle(cornerRadius: 40)
                    .stroke(.secondary, lineWidth: 1.5))
    }
}
