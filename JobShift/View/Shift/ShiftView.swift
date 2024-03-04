import Foundation
import SwiftUI

struct ShiftView: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
//    @EnvironmentObject private var viewModel: ShiftViewModel
    
    var body: some View {
        VStack {
//            CalendarView(
//                selectionBehavior: viewModel.dateSelectionBehavior,
//                decorationFor: viewModel.decorator
//            )
//            .padding(.horizontal)
//            .frame(height: 460)
//            .onAppear {
//                viewModel.onAppear()
//            }
            Spacer()
        }
        .background(Color(.systemGroupedBackground))
    }
}
