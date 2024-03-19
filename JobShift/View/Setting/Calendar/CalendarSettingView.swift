import SwiftUI

struct CalendarSettingView: View {
    @State var viewModel = CalendarSettingViewModel()
    
    var body: some View {
        List {
            Section {
                Toggle(isOn: $viewModel.appState.isShowOnlyJobEvent) {
                    Text("バイトの予定のみを表示")
                }
            }
            Section {
                Picker("デフォルトの追加先", selection: $viewModel.defaultCalendar) {
                    ForEach(viewModel.calendars, id: \.self) { calendar in
                        Text(calendar.name)
                    }
                }
            }
            Section(header: Text("使用するカレンダー")) {
                ForEach(viewModel.calendars, id: \.self) { calendar in
                    Toggle(isOn: Binding<Bool>(
                        get: { calendar.isActive },
                        set: { value in
                            calendar.isActive = value
                        }
                    )) {
                        Text(calendar.name)
                    }
                }
            }
        }
        .onWillDisappear {
            viewModel.onWillDisappear()
        }
        .environment(\.editMode, .constant(.active))
        .navigationTitle("カレンダー")
        .navigationBarTitleDisplayMode(.inline)
    }
}
