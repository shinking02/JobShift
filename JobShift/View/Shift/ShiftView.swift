import Foundation
import SwiftUI

struct ShiftView: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(ShiftViewModel.self) var viewModel
    
    var body: some View {
        VStack {
            CalendarView(viewModel: viewModel)
            .padding(.horizontal)
            .frame(height: 460)
            Spacer()
        }
        .background(Color(.systemGroupedBackground))
        .onAppear() {
            viewModel.onAppear()
        }
    }
}
