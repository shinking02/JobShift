import SwiftUI

struct OTJobAddView: View {
    @Environment(\.dismiss) var dismiss
    @State var viewModel: OTJobAddViewModel
    
    var body: some View {
        NavigationView {
            Form {
                OTJobFormView(viewModel: viewModel)
            }
            .scrollDismissesKeyboard(.immediately)
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
            .navigationTitle("新規単発バイト")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
