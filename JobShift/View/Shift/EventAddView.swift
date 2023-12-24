import Foundation
import SwiftUI
import GoogleAPIClientForREST
import SwiftData

struct EventAddView: View {
    @EnvironmentObject var userState: UserState
    @EnvironmentObject var eventStore: EventStore
    @Environment(\.dismiss) var dismiss
    @Query var jobs: [Job]
    @State var suggestDate: DateComponents
    @State var newEvent: Event
    @State var selectedCal: GTLRCalendar_CalendarListEntry
    @State var selectedJob: Job
    @State private var isUpdating = false
    @State private var isDateError = false
    @State private var startDate: Date = Date()
    @State private var endDate: Date = Date()
    @State private var isAllDay = true
    @State private var suggests: [Suggest] = []
    @State private var selectedSuggest: Suggest? = nil
    @State private var showAddError = false
    
    var body: some View {
        NavigationView {
            List(selection: $selectedSuggest) {
                Section(footer: Text(isDateError ? "開始日が終了日より後になっています" : "").foregroundColor(.red)) {
                    Picker("バイト", selection: $selectedJob) {
                        ForEach(jobs, id: \.self) { job in
                            HStack {
                                Text(job.name).tag(job.name)
                                Spacer()
                                Text("")
                            }
                        }
                    }
                    Toggle("終日", isOn: $isAllDay)
                    datePickerWithOnChange("開始", selection: $startDate, displayedComponents: isAllDay ? .date : [.date, .hourAndMinute])
                        .onChange(of: startDate) {
                            self.suggestDate = Calendar.current.dateComponents([.year, .month, .day], from: startDate)
                            // 提案の処理が遅いので非同期で処理
                            DispatchQueue.global().async {
                                DispatchQueue.main.async {
                                    withAnimation {
                                        self.suggests = eventStore.getSuggest(jobs: jobs, dateComponents: suggestDate)
                                    }
                                }
                            }
                        }
                    datePickerWithOnChange("終了", selection: $endDate, displayedComponents: isAllDay ? .date : [.date, .hourAndMinute])
                    Picker("追加先", selection: $selectedCal) {
                        ForEach(userState.calendars, id: \.self) { calendar in
                            Text(calendar.summary ?? "")
                        }
                    }
                    .onChange(of: selectedCal) {
                        userState.mainCal = selectedCal
                        UserDefaults.standard.set(selectedCal.identifier, forKey: UserDefaultsKeys.mainCalId)
                    }
                }
                if suggests.count > 0 {
                    Section(header: Text("提案")) {
                        ForEach(suggests) { sug in
                            HStack {
                                Image(systemName: "circle.fill")
                                    .foregroundColor(sug.job.color.getColor())
                                    .font(.caption)
                                Text(sug.job.name)

                                if sug == selectedSuggest {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.accentColor)
                                }
                                Spacer()
                                VStack {
                                    let (start, end) = getDateText(suggest: sug)
                                    Text(start)
                                    if let end = end {
                                        Text(end)
                                    }
                                }
                                .font(.caption)
                                .foregroundColor(.secondary)
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                setEventFromSuggest(suggest: sug)
                            }
                        }
                    }
                }
            }
            .navigationTitle("新規イベント")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("キャンセル") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("追加") {
                        self.isUpdating = true
                        addEvent() { success in
                            if success {
                                self.isUpdating = false
                                dismiss()
                            } else {
                                self.showAddError = true
                            }
                            self.isUpdating = false
                        }
                    }
                    .disabled(isUpdating || isDateError)
                    .alert("追加に失敗しました", isPresented: $showAddError) {
                        Button("OK", role: .cancel) {}
                    }
                }
            }
            .onAppear {
                self.suggests = eventStore.getSuggest(jobs: jobs, dateComponents: suggestDate)
                self.startDate = suggestDate.date ?? Date()
                self.endDate = suggestDate.date ?? Date()
            }
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
    
    private func setEventFromSuggest(suggest: Suggest) {
        self.selectedSuggest = suggest
        self.selectedJob = suggest.job
        self.startDate = suggest.start
        self.endDate = suggest.end
        self.isAllDay = suggest.isAllDay
    }
    
    private func getDateText(suggest: Suggest) -> (String, String?) {
        if !suggest.isAllDay {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "HH:mm"
            return (dateFormatter.string(from: suggest.start), dateFormatter.string(from: suggest.end))
        }
        return ("終日", nil)
    }
    private func addEvent(completion: @escaping (_ success: Bool) -> Void) {
        let newEvent = GTLRCalendar_Event()
        let newEventStart = GTLRCalendar_EventDateTime()
        let newEventEnd = GTLRCalendar_EventDateTime()
        let calendar = Calendar.current
        let (gtlrDateStart, gtlrDateEnd): (GTLRDateTime, GTLRDateTime) = {
            if self.isAllDay {
                let startComponent = calendar.dateComponents([.year, .month, .day], from: startDate)
                let endComponent = calendar.dateComponents([.year, .month, .day], from: endDate)
                return (GTLRDateTime(forAllDayWith: calendar.date(byAdding: .day, value: 1, to: calendar.date(from: startComponent)!)!),
                        GTLRDateTime(forAllDayWith: calendar.date(byAdding: .day, value: 2, to: calendar.date(from: endComponent)!)!))
            } else {
                return (GTLRDateTime(date: startDate), GTLRDateTime(date: endDate))
            }
        }()
        if self.isAllDay {
            newEventStart.date = gtlrDateStart
            newEventEnd.date = gtlrDateEnd
        } else {
            newEventStart.dateTime = gtlrDateStart
            newEventEnd.dateTime = gtlrDateEnd
        }
        newEvent.start = newEventStart
        newEvent.end = newEventEnd
        newEvent.summary = selectedJob.name
        eventStore.addEvent(event: Event(calId: selectedCal.identifier ?? "", gEvent: newEvent)) { success in
            completion(success)
        }
    }
}
