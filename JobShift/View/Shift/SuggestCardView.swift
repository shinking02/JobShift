import SwiftUI

struct SuggestCardView: View {
    var suggest: ShiftViewEvent
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(.clear)
                .overlay(
                    RadialGradient(
                        gradient: Gradient(colors: [suggest.color, Color.clear]),
                        center: .bottomTrailing,
                        startRadius: 8,
                        endRadius: 80
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(.regularMaterial)
                )
            VStack {
                HStack {
                    Text(suggest.title)
                    Spacer()
                }
                HStack {
                    Text(suggest.detailText1)
                        .font(.headline)
                    Spacer()
                }
                .font(.caption)
            }
            .padding(.horizontal, 8)
        }
        .frame(width: 140, height: 50)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}
