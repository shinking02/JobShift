import SwiftUI

struct OTJobEditView: View {
    @Environment(\.dismiss) var dismiss
    @State var viewModel: OTJobEditViewModel
    
    var body: some View {
        Form {
            // Validation is done by viewModel
            OTJobFormView(viewModel: viewModel)
            Section {
                HStack {
                    Spacer()
                    Button("削除") {
                        viewModel.deleteButtonTapped()
                    }
                    .alert("\(viewModel.otJob.name)を削除しますか？", isPresented: $viewModel.showDeleteAlert) {
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
            viewModel.onDisappear()
        }
        .scrollDismissesKeyboard(.immediately)
        .navigationTitle(viewModel.otJob.name)
    }
}
