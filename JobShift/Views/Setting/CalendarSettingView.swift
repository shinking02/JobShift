import SwiftUI

struct CalendarSettingView: View {
    @State private var calendars: [UserCalendar] = []
    @State private var isShowOnlyJobEvent = false
    @State private var selectedDefaultCalendar: UserCalendar = CalendarManager.shared.defaultCalendar
    
    var body: some View {
        List {
            Section {
                Picker("デフォルトの追加先", selection: $selectedDefaultCalendar) {
                    ForEach(calendars) { calendar in
                        Text(calendar.summary).tag(calendar)
                    }
                }
                .onChange(of: selectedDefaultCalendar) { CalendarManager.shared.setDefaultCalendar(selectedDefaultCalendar) }
                Toggle(isOn: $isShowOnlyJobEvent) {
                    Text("バイト予定のみ表示")
                }
                .onChange(of: isShowOnlyJobEvent) { CalendarManager.shared.setIsShowOnlyJobEvent(isShowOnlyJobEvent) }
            }
            Section(header: Text("使用するカレンダー")) {
                ForEach($calendars) { $calendar in
                    Toggle(isOn: $calendar.isActive) {
                        Text(calendar.summary)
                    }
                }
            }
        }
        .onAppear {
            calendars = CalendarManager.shared.calendars
            isShowOnlyJobEvent = Storage.getIsShowOnlyJobEvent()
            selectedDefaultCalendar = CalendarManager.shared.defaultCalendar
        }
        .navigationTitle("カレンダー")
        .navigationBarTitleDisplayMode(.inline)
    }
}
