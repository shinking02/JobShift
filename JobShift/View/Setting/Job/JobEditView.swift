import SwiftUI

struct JobEditView: View {
    @Bindable var job: Job
    @StateObject private var viewModel: JobEditViewModel
    @Environment(\.dismiss) var dismiss
    @State private var showDeleteAlert = false
    
    init(job: Job) {
        self._job = Bindable(job)
        self._viewModel = StateObject(wrappedValue: JobEditViewModel(job: job))
    }
    var body: some View {
        List {
            JobFormView(viewModel: viewModel)
            Section {
                HStack {
                    Spacer()
                    Button("削除") {
                        showDeleteAlert = true
                    }
                    .alert("\(job.name)を削除しますか？", isPresented: $showDeleteAlert) {
                        Button("キャンセル", role: .cancel) {}
                        Button("削除", role: .destructive) {
                            viewModel.delete()
                            dismiss()
                        }
                    }
                    .foregroundColor(.red)
                    Spacer()
                }
            }
        }
        // onDisappearだとJobSettingViewのonAppearより後に実行される場合がある
        .onWillDisappear {
            viewModel.trySave()
        }
        .scrollDismissesKeyboard(.immediately)
        .navigationTitle(job.name)
    }
}
