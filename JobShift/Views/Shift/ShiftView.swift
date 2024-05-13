import SwiftUI

struct ShiftView: View {
    @Binding var isShiftSheetPresented: Bool
    @State private var selectedDate = Date()

    var body: some View {
        NavigationStack {
            VStack {
                CalendarView { dateComponents in
                    selectedDate = dateComponents.date ?? Date()
                }
                .frame(height: 400)
                Spacer()
            }
            .navigationTitle("シフト")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $isShiftSheetPresented) {
                ShiftSheetView(selectedDate: $selectedDate)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    .presentationDetents([.height(240), .large])
                    .presentationCornerRadius(18)
                    .presentationBackground(.bar)
                    .presentationBackgroundInteraction(.enabled(upThrough: .large))
                    .interactiveDismissDisabled()
                    .bottomMaskForSheet()
            }
        }
    }
}
