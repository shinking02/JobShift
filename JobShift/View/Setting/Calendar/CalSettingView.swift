import Foundation
import SwiftUI
import GoogleAPIClientForREST
import SwiftData

struct CalSettingView: View {
    @EnvironmentObject var userState: UserState
    @Query private var jobs: [Job]
    @EnvironmentObject var eventStore: EventStore
    @State private var selectedCalendars: Set<GTLRCalendar_CalendarListEntry> = []
    @State private var showJobOnly: Bool = UserDefaults.standard.bool(forKey: UserDefaultsKeys.showJobOnly)
    @State private var disabledJobOnlyFrag = false

    var body: some View {
        List(selection: $selectedCalendars) {
            Section {
                Toggle("バイトの予定のみ表示", isOn: $showJobOnly)
                    .onChange(of: showJobOnly) {
                        UserDefaults.standard.set(showJobOnly, forKey: UserDefaultsKeys.showJobOnly)
                        if !showJobOnly {
                            self.disabledJobOnlyFrag = true
                        }
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
            self.disabledJobOnlyFrag = false
            if selectedCalendars.isEmpty {
                self.selectedCalendars = Set(userState.selectedCalendars)
            }
        }
        .onDisappear {
            if Set(userState.selectedCalendars) != selectedCalendars {
                let addedCals = selectedCalendars.subtracting(Set(userState.selectedCalendars))
                let deletedCals = Set(userState.selectedCalendars).subtracting(selectedCalendars)
                eventStore.deleteCalendarFromStore(calendars: Array(deletedCals))
                eventStore.updateCalendarForStore(calendars: Array(addedCals)) { success in
                    if success {
                        userState.selectedCalendars = Array(selectedCalendars)
                        let disabledCals = userState.calendars.filter { !Array(selectedCalendars).contains($0) }
                        UserDefaults.standard.set(disabledCals.map { $0.identifier }, forKey: UserDefaultsKeys.disabledCalIds)
                    }
                }
            } else if showJobOnly == false && disabledJobOnlyFrag {
                eventStore.updateCalendarForStore(calendars: userState.selectedCalendars) { success in }
            }
         }
    }
}
