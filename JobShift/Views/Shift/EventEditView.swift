import SwiftUI
import RealmSwift

struct EventEditView: View {
    @State var eventId: String
    @State var beforeCalendarId: String
    @State var summary: String
    @State var start: Date
    @State var end: Date
    @State var isAllDay: Bool
    @State private var calendarId = CalendarManager.shared.defaultCalendar.id
    @State private var deleteConfirmAlert = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("イベント名")) {
                    TextField("", text: $summary)
                }
                Section {
                    Toggle("終日", isOn: $isAllDay)
                    DatePicker("開始", selection: $start, displayedComponents: isAllDay ? [.date] : [.date, .hourAndMinute]).frame(height: 30)
                    DatePicker("終了", selection: $end, displayedComponents: isAllDay ? [.date] : [.date, .hourAndMinute]).frame(height: 30)
                }
                Section {
                    Picker("追加先", selection: $calendarId) {
                        ForEach(CalendarManager.shared.calendars.map { $0.id }, id: \.self) { calendar in
                            Text(CalendarManager.shared.calendars.first(where: { $0.id == calendar })?.summary ?? "")
                        }
                    }
                }
                Section {
                    Button {
                        deleteConfirmAlert = true
                    } label: {
                        Text("削除")
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                    .tint(.red)
                    .alert("確認", isPresented: $deleteConfirmAlert) {
                        Button("キャンセル", role: .cancel) {}
                        Button("削除", role: .destructive) {
                            Task {
                                await CalendarManager.shared.deleteEvent(eventId: eventId, calendarId: beforeCalendarId)
                            }
                            dismiss()
                        }
                    } message: {
                        Text("イベントを削除しますか？")
                    }
                }
            }
            .navigationBarTitle("イベントを編集")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("キャンセル") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("完了") {
                        let editedEvent = Event()
                        editedEvent.id = eventId
                        editedEvent.calendarId = calendarId
                        editedEvent.summary = summary
                        editedEvent.isAllDay = isAllDay
                        editedEvent.start = start
                        editedEvent.end = end
                        Task {
                            await CalendarManager.shared.editEvent(event: editedEvent, beforeCalendarId: beforeCalendarId)
                        }
                        dismiss()
                    }
                    .disabled((isAllDay ? !start.isSameDay(end) && start >= end : start >= end) || summary.isEmpty)
                }
            }
            .onAppear {
                calendarId = beforeCalendarId
            }
        }
    }
}

