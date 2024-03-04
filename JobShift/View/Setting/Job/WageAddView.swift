import SwiftUI

struct WageAddView: View {
    @State var viewModel: JobFormViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            List {
                DatePicker("昇給日", selection: $viewModel.newWageDate, in: viewModel.startDate..., displayedComponents: .date)
                            .environment(\.locale, Locale(identifier: "ja_JP"))
                            .frame(height: 30)
                TextField("昇給後の時給(円)", text: $viewModel.newWageString)
                    .keyboardType(.numberPad)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("キャンセル") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("追加") {
                        viewModel.addWage()
                        dismiss()
                    }.disabled(viewModel.newWageValidateError)
                }
            }
            .navigationTitle("昇給履歴を追加")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
