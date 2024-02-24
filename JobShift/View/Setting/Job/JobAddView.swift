import SwiftUI

struct JobAddView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel = JobAddViewModel()
    
    var body: some View {
        NavigationView {
            List {
                JobFormView(viewModel: viewModel)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("キャンセル") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("追加") {
                        viewModel.handleAddButton()
                        dismiss()
                    }.disabled(viewModel.validationError)
                }
            }
            .scrollDismissesKeyboard(.immediately)
            .navigationTitle("新規バイト")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
