import Foundation
import SwiftUI

struct CalendarSettingView: View {
    @State private var allCalendars: [UserCalendar] = UserDefaultsData.shared.getAllCalendars()
    @State private var selectedCalendars: Set<UserCalendar> = Set(UserDefaultsData.shared.getActiveCalendars())
    @State private var showOnlyJobEvent: Bool = UserDefaultsData.shared.getShowOnlyJobEventSetting()
    
    var body: some View {
        List {
            Section {
                Toggle(isOn: $showOnlyJobEvent) {
                    Text("バイトの予定のみを表示")
                }
                .onChange(of: showOnlyJobEvent) {
                    UserDefaultsData.shared.setShowOnlyJobEventSetting(showOnlyJobEvent)
                }
            }
            Section(header: Text("使用するカレンダー")) {
                ForEach(allCalendars, id: \.self) { calendar in
                    Toggle(isOn: Binding<Bool>(
                        get: { selectedCalendars.contains(calendar) },
                        set: { isSelected in
                            if isSelected {
                                selectedCalendars.insert(calendar)
                            } else {
                                selectedCalendars.remove(calendar)
                            }
                        }
                    )) {
                        Text(calendar.name)
                    }
                }
            }
            .onChange(of: selectedCalendars) {
                UserDefaultsData.shared.setActiveCalendars(Array(selectedCalendars))
            }
        }
        .onAppear {
            selectedCalendars = Set(UserDefaultsData.shared.getActiveCalendars())
            showOnlyJobEvent = UserDefaultsData.shared.getShowOnlyJobEventSetting()
        }
        .environment(\.editMode, .constant(.active))
        .navigationTitle("カレンダー")
    }
}
