import SwiftData
import SwiftUI

struct ShiftView: View {
    @Binding var isWelcomePresented: Bool
    @State private var selectedDate = Date()
    @State private var isSheetPresented = false
    @State private var isInitial = true
    @Query(sort: \Job.order) private var jobs: [Job]
    @Query private var otJobs: [OneTimeJob]

    var body: some View {
        NavigationStack {
            VStack {
                CalendarView(
                    didSelectDate: { dateComponents in
                        selectedDate = dateComponents.date ?? Date()
                    },
                    jobs: jobs,
                    otJobs: otJobs,
                    isShowOnlyJobEvent: CalendarManager.shared.isShowOnlyJobEvent,
                    activeCalendars: CalendarManager.shared.calendars.compactMap({ $0.isActive ? $0 : nil })
                )
                .frame(height: 470)
                Spacer()
            }
            .onAppear {
                if isInitial && !isWelcomePresented {
                    isInitial = false
                    Task {
                        try await Task.sleep(millisecond: 400)
                        isSheetPresented = true
                    }
                    return
                }
                if !isWelcomePresented && AppState.shared.finishFirstSyncProcess {
                    isSheetPresented = true
                }
            }
            .onWillDisappear {
                isSheetPresented = false
            }
            .onChange(of: isWelcomePresented) {
                if !isWelcomePresented {
                    Task {
                        try await Task.sleep(seconds: 1)
                        isSheetPresented = true
                    }
                }
            }
            .sheet(isPresented: $isSheetPresented) {
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
