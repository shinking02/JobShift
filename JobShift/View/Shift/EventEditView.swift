import SwiftUI

struct EventEditView: View {
    var event: ShiftViewEvent
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: EventEditViewModel
    @State private var showDeleteAlert = false
    
    init(event: ShiftViewEvent) {
        self.event = event
        _viewModel = State(initialValue: EventEditViewModel(event: event))
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("タイトル")) {
                    TextField("", text: $viewModel.title)
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
                Section {
                    HStack {
                        Spacer()
                        Button("イベントを削除") {
                            showDeleteAlert = true
                        }
                        .alert("\(event.title)を削除しますか", isPresented: $showDeleteAlert) {
                            Button("キャンセル", role: .cancel) {}
                            Button("削除", role: .destructive) {
                                Task {
                                    await viewModel.deleteButtonTapped()
                                    dismiss()
                                }
                            }
                        }
                        .foregroundColor(.red)
                        Spacer()
                    }
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
                            await viewModel.updateButtonTapped()
                            dismiss()
                        }
                    }) {
                        if viewModel.apiLoading {
                            ProgressView()
                        } else {
                            Text("完了")
                        }
                    }
                    .disabled(viewModel.dateError || viewModel.title.isEmpty)
                }
            }
            .navigationTitle("予定の編集")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
