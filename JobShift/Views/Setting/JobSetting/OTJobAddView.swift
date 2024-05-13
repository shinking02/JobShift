import SwiftUI

struct OTJobAddView: View {
    @State var otJob: OneTimeJob = .init()
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @State private var salary = ""
    
    
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
                    TextField("金額(円)", text: $salary)
                        .keyboardType(.numberPad)
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
            }
            .navigationTitle("新規単発バイト")
            .navigationBarTitleDisplayMode(.inline)
            .scrollDismissesKeyboard(.immediately)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Text("キャンセル")
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        otJob.salary = Int(salary) ?? 0
                        context.insert(otJob)
                        dismiss()
                    } label: {
                        Text("追加")
                    }
                    .disabled(otJob.name.isEmpty || salary.isEmpty)
                }
            }
        }
    }
}
