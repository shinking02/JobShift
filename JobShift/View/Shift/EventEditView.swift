import Foundation
import SwiftUI
import GoogleAPIClientForREST

struct EventEditView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject private var eventStore: EventStore
    @State var event: Event
    @State var editEvent: Event = Event()
    @State var isAllDay = false
    @State var startDate = Date()
    @State var endDate = Date()
    @State var isUpdating = false
    @State var isDateError = false
    @State var showDeleteAlert = false
    @State var showSaveError = false
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("イベント名")) {
                    TextField("", text: Binding($editEvent.gEvent.summary)!)
                }
                Section(footer: Text(isDateError ? "開始日が終了日より後になっています" : "").foregroundColor(.red)) {
                    Toggle("終日", isOn: $isAllDay)
                    datePickerWithOnChange("開始", selection: $startDate, displayedComponents: isAllDay ? .date : [.date, .hourAndMinute])
                    datePickerWithOnChange("終了", selection: $endDate, displayedComponents: isAllDay ? .date : [.date, .hourAndMinute])
                }
                Section {
                    Button(action: {
                        self.showDeleteAlert = true
                    }) {
                        HStack {
                            Spacer()
                            Text("イベントを削除")
                                .foregroundColor(.red)
                            Spacer()
                        }
                    }
                    .alert("\(editEvent.gEvent.summary ?? "")を削除しますか？", isPresented: $showDeleteAlert) {
                        Button("削除", role: .destructive) {
                            eventStore.deleteEvent(event: event) { success in }
                            dismiss()
                        }
                        Button("キャンセル", role: .cancel) {}
                    }
                }
            }
            .navigationTitle("イベントを編集")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("キャンセル") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("保存") {
                        self.isUpdating = true
                        updateEvent(event: editEvent) { success in
                            if success {
                                dismiss()
                            } else {
                                self.showSaveError = true
                            }
                            self.isUpdating = false
                        }
                    }
                    .alert("保存に失敗しました", isPresented: $showSaveError) {
                        Button("OK", role: .cancel) {}
                    }
                    .disabled(isUpdating || isDateError)
                    
                }
            }
        }
        .onAppear() {
            if let _ = event.gEvent.start?.date?.date {
                self.isAllDay = true
                self.startDate = event.gEvent.start?.date?.date ?? Date()
                self.endDate =  Calendar.current.date(byAdding: .day, value: -1, to: event.gEvent.end?.date?.date ?? Date()) ?? Date()
            } else {
                self.startDate = event.gEvent.start?.dateTime?.date ?? Date()
                self.endDate = event.gEvent.end?.dateTime?.date ?? Date()
            }
            self.editEvent = event
        }
    }
    private func updateEvent(event: Event, completion: @escaping (_ success: Bool) -> Void) {
        let calendar = Calendar.current
        let startEvent = GTLRCalendar_EventDateTime()
        let endEvent = GTLRCalendar_EventDateTime()
        if isAllDay {
            event.gEvent.start?.dateTime = nil
            event.gEvent.end?.dateTime = nil
            let startComponent = calendar.dateComponents([.year, .month, .day], from: startDate)
            let endTempComponent = calendar.dateComponents([.year, .month, .day], from: endDate)
            let gtlrDateStart = GTLRDateTime(forAllDayWith: calendar.date(byAdding: .day, value: 1, to: calendar.date(from: startComponent)!)!)
            let gtlrDateEnd = GTLRDateTime(forAllDayWith: calendar.date(byAdding: .day, value: 2, to: calendar.date(from: endTempComponent)!)!)
            startEvent.date = gtlrDateStart
            endEvent.date = gtlrDateEnd
        } else {
            event.gEvent.start?.date = nil
            event.gEvent.end?.date = nil
            let gtlrDateStart = GTLRDateTime(date: startDate)
            let gtlrDateEnd = GTLRDateTime(date: endDate)
            startEvent.dateTime = gtlrDateStart
            endEvent.dateTime = gtlrDateEnd
        }
        event.gEvent.start = startEvent
        event.gEvent.end = endEvent
        eventStore.updateEvent(event: event) { success in
            completion(success)
        }
    }
    private func datePickerWithOnChange(_ label: String, selection: Binding<Date>, displayedComponents: DatePickerComponents = []) -> some View {
        DatePicker(label, selection: selection, displayedComponents: displayedComponents)
            .environment(\.locale, Locale(identifier: "ja_JP"))
            .frame(height: 30)
            .onChange(of: selection.wrappedValue) {
                self.isDateError = startDate.compare(endDate) == .orderedDescending
            }
    }
}
