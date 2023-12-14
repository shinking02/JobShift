import Foundation
import SwiftUI
import GoogleAPIClientForREST

struct CalSettingView: View {
    @EnvironmentObject var userState: UserState
    @State private var selectedCalendars: Set<GTLRCalendar_CalendarListEntry> = []
    @State private var showJobOnly: Bool = UserDefaults.standard.bool(forKey: UserDefaultsKeys.showJobOnly)

    var body: some View {
        List(selection: $selectedCalendars) {
            Section {
                Toggle("バイトの予定のみ表示", isOn: $showJobOnly)
                    .onChange(of: showJobOnly) {
                        UserDefaults.standard.set(showJobOnly, forKey: UserDefaultsKeys.showJobOnly)
                    }
            }
            Section(header: Text("使用するカレンダー")) {
                ForEach(userState.calendars, id: \.self) { calendar in
                    Text(calendar.summary ?? "")
                        .listRowBackground(Color(UIColor.secondarySystemGroupedBackground))
                }
            }
        }
        .environment(\.editMode, .constant(.active))
        .navigationTitle("カレンダー")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if selectedCalendars.isEmpty {
                self.selectedCalendars = Set(userState.selectedCalendars)
            }
        }
        .onChange(of: selectedCalendars) {
            //TODO: eventStoreの更新, userState.calendarsとselectedCalendarsを比較し、除外対象をuserDefaultに保存
        }
    }
}
