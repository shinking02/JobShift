import SwiftUI

struct JobEditView: View {
    @State var viewModel: JobEditViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        List {
            JobFormView(viewModel: viewModel)
            Section {
                HStack {
                    Spacer()
                    Button("削除") { viewModel.deleteButtonTapped() }
                        .alert("\(viewModel.job.name)を削除しますか？", isPresented: $viewModel.showDeleteAlert) {
                        Button("キャンセル", role: .cancel) {}
                        Button("削除", role: .destructive) {
                            viewModel.jobDelete()
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
            viewModel.onDisappear()
        }
        .scrollDismissesKeyboard(.immediately)
        .navigationTitle(viewModel.job.name)
    }
}
