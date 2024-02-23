import SwiftUI

struct CalendarSettingView: View {
    @StateObject var viewModel = CalendarSettingViewModel()
    
    var body: some View {
        List {
            Section {
                Toggle(isOn: $viewModel.showOnlyJobEvent) {
                    Text("バイトの予定のみを表示")
                }
                .onChange(of: viewModel.showOnlyJobEvent) {
                    viewModel.updateShowOnlyJobEventSetting()
                }
            }
            Section(header: Text("使用するカレンダー")) {
                ForEach(viewModel.allCalendars, id: \.self) { calendar in
                    Toggle(isOn: Binding<Bool>(
                        get: { viewModel.selectedCalendars.contains(calendar) },
                        set: { _ in viewModel.toggleCalendarSelection(calendar) }
                    )) {
                        Text(calendar.name)
                    }
                }
            }
        }
        .environment(\.editMode, .constant(.active))
        .navigationTitle("カレンダー設定")
        .navigationBarTitleDisplayMode(.inline)
    }
}
