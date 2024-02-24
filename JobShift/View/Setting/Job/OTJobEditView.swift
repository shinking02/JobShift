import SwiftUI

struct OTJobEditView: View {
    @Bindable var otJob: OneTimeJob
    @StateObject private var viewModel: OTJobEditViewModel
    @Environment(\.dismiss) var dismiss
    @State private var showDeleteAlert = false
    
    init(otJob: OneTimeJob) {
        self._otJob = Bindable(otJob)
        self._viewModel = StateObject(wrappedValue: OTJobEditViewModel(otJob: otJob))
    }
    
    var body: some View {
        Form {
            // Validation is done by viewModel
            OTJobFormView(
                name: $viewModel.name,
                salary: $viewModel.salary,
                date: $otJob.date,
                isCommuteWage: $viewModel.isCommuteWage,
                commuteWage: $viewModel.commuteWage,
                summary: $otJob.summary
            )
            Section {
                HStack {
                    Spacer()
                    Button("削除") {
                        showDeleteAlert = true
                    }
                    .alert("\(otJob.name)を削除しますか？", isPresented: $showDeleteAlert) {
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
        .onDisappear() {
            viewModel.validateAndUpdate()
        }
        .scrollDismissesKeyboard(.immediately)
        .navigationTitle(otJob.name)
    }
}
