import SwiftUI

struct WageEditView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var wage: JobWage
    @State private var showDeleteAlert = false
    let canDelete: Bool
    let onDelete: () -> Void

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    DatePicker("開始日", selection: $wage.start, displayedComponents: [.date])
                }
                Section(
                    header: Text("基本給"),
                    footer: Text("時給・日給を入力してください。")
                ) {
                    NumberTextField(number: $wage.wage, label: "金額")
                }
                Section {
                    Button {
                        showDeleteAlert = true
                    } label: {
                        Text("削除")
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                    .tint(.red)
                    .disabled(!canDelete)
                    .alert("確認", isPresented: $showDeleteAlert) {
                        Button("キャンセル", role: .cancel) {}
                        Button("削除", role: .destructive) {
                            onDelete()
                            dismiss()
                        }
                    } message: {
                        Text("基本給を削除しますか？")
                    }
                }
            }
            .navigationTitle("基本給を編集")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
