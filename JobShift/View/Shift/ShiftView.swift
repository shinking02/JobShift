import Foundation
import SwiftUI

struct ShiftView: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(ShiftViewModel.self) var viewModel
    
    var body: some View {
        VStack {
            CalendarView(
                selectionBehavior: viewModel.selectionBehavior,
                decorationFor: viewModel.decorationFor
            )
            .padding(.horizontal)
            .frame(height: 460)
            Spacer()
        }
        .background(Color(.systemGroupedBackground))
    }
}
