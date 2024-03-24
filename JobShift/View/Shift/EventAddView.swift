import SwiftUI

struct EventAddView: View {
    var event: ShiftViewEvent
    @State private var viewModel: EventAddViewModel
    @Environment(\.dismiss) private var dismiss
    
    init(event: ShiftViewEvent) {
        self.event = event
        _viewModel = State(initialValue: EventAddViewModel(event: event))
    }
    var body: some View {
        NavigationView {
            Form {
                Section {
                    Picker("バイト", selection: $viewModel.jobSelection) {
                        ForEach(viewModel.jobs, id: \.self) { job in
                            Text(job.name)
                        }
                    }
                }
                Section(footer: viewModel.dateError ? Text("開始日時が終了日時より後になっています").foregroundStyle(.red) : nil) {
                    Toggle("終日", isOn: $viewModel.isAllday)
                    DatePicker("開始", selection: $viewModel.start, displayedComponents: viewModel.isAllday ? [.date] : [.date, .hourAndMinute])
                        .environment(\.locale, Locale(identifier: "ja_JP"))
                        .frame(height: 30)
                    DatePicker("終了", selection: $viewModel.end, displayedComponents: viewModel.isAllday ? [.date] : [.date, .hourAndMinute])
                        .environment(\.locale, Locale(identifier: "ja_JP"))
                        .frame(height: 30)
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("キャンセル") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        Task {
                            await viewModel.addButtonTapped()
                            dismiss()
                        }
                    }, label: {
                        if viewModel.apiLoading {
                            ProgressView()
                        } else {
                            Text("追加")
                        }
                    })
                    .disabled(viewModel.dateError)
                }
            }
            .navigationTitle("予定の追加")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
