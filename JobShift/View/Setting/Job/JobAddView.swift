import SwiftUI

struct JobAddView: View {
    @Environment(\.dismiss) var dismiss
    @State var viewModel: JobAddViewModel
    
    var body: some View {
        NavigationView {
            List {
                JobFormView(viewModel: viewModel)
                EmptyView()
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("キャンセル") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("追加") {
                        viewModel.addButtonTapped()
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
