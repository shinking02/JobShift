import SwiftUI

struct SalaryEditView: View {
    @Binding var history: JobSalaryHistory
    let title: String
    let onDelete: () -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var showDeleteAlert = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section(
                    header: Text("給与"),
                    footer: Text("交通費を含めてください。")
                ) {
                    NumberTextField(number: $history.salary, label: "金額")
                }
                Section {
                    Button {
                        showDeleteAlert = true
                    } label: {
                        Text("削除")
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                    .tint(.red)
                    .alert("確認", isPresented: $showDeleteAlert) {
                        Button("キャンセル", role: .cancel) {}
                        Button("削除", role: .destructive) {
                            onDelete()
                            dismiss()
                        }
                    } message: {
                        Text("給与実績を削除しますか？")
                    }
                }
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
