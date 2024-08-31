import SwiftUI
import SwiftData

struct EventAddView: View {
    @State var selectedJob: Job
    @State var start: Date
    @State var end: Date
    @State var isAllDay: Bool
    @Query(sort: \Job.order) private var jobs: [Job]
    @Environment(\.dismiss) private var dismiss
    @State private var calendarId = CalendarManager.shared.defaultCalendar.id
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    Picker("バイト", selection: $selectedJob) {
                        ForEach(jobs, id: \.self) { job in
                            Text(job.name)
                        }
                    }
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
            }
            .navigationBarTitle("新規イベント")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("キャンセル") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("追加") {
                        Task {
                            await CalendarManager.shared.addEvent(summary: selectedJob.name, startDate: start, endDate: end, isAllDay: isAllDay, calendarId: calendarId)
                        }
                        dismiss()
                    }
                    .disabled(start >= end)
                }
            }
        }
    }
}
