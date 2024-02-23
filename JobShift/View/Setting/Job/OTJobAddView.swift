import SwiftUI

struct OTJobAddView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel = OTJobAddViewModel()
    
    var body: some View {
        NavigationView {
            Form {
                OTJobFormView(
                    name: $viewModel.name,
                    salary: $viewModel.salary,
                    date: $viewModel.date,
                    isCommuteWage: $viewModel.isCommuteWage,
                    commuteWage: $viewModel.commuteWage,
                    summary: $viewModel.summary
                )
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
                        viewModel.handleAddButton()
                        dismiss()
                    }.disabled(viewModel.validationError)
                }
            }
            .navigationTitle("新規単発バイト")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
