import SwiftUI

struct OTJobEditView: View {
    @Bindable var otJob: OneTimeJob
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @State private var showDeleteAlert = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section(
                    header: Text("名前")
                ) {
                    TextField("単発バイトA", text: $otJob.name)
                }
                Section {
                    DatePicker("勤務日", selection: $otJob.date, displayedComponents: [.date])
                }
                Section(
                    header: Text("給与"),
                    footer: Text("交通費を含めてください。")
                ) {
                    NumberTextField(number: $otJob.salary, label: "金額(円)")
                }
                Section(
                    footer: Text(otJob.isCommuteWage ? "往復の金額を入力してください" : "")
                ) {
                    Toggle("通勤手当", isOn: $otJob.isCommuteWage)
                    if otJob.isCommuteWage {
                        NumberTextField(number: $otJob.commuteWage, label: "往復金額(円)")
                    }
                }
                Section(
                    header: Text("メモ")
                ) {
                    TextField("手渡し", text: $otJob.summary)
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
                            context.delete(otJob)
                            dismiss()
                        }
                    } message: {
                        Text("\(otJob.name)を削除しますか？")
                    }
                }
            }
            .navigationTitle(otJob.name)
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
