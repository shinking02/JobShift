import Foundation
import SwiftUI

struct OTJobEditView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) var dismiss
    @Bindable var editOtJob: OneTimeJob
    @State private var showDeleteAlert = false
    
    var body: some View {
        List {
            Section(header: Text("名前")) {
                TextField("", text: $editOtJob.name)
            }
            Section {
                DatePicker("勤務日", selection: $editOtJob.date, displayedComponents: .date)
                    .frame(height: 30)
                    .environment(\.locale, Locale(identifier: "ja_JP"))
                HStack {
                    Text("給料")
                    TextField("", value: $editOtJob.salary, formatter: NumberFormatter())
                        .multilineTextAlignment(TextAlignment.trailing)
                        .keyboardType(.numberPad)
                    Text("円")
                        .foregroundColor(.secondary)
                }
                Toggle("通勤手当", isOn: $editOtJob.isCommuteWage.animation())
                if editOtJob.isCommuteWage {
                    HStack {
                        Text("往復料金")
                        TextField("", value: $editOtJob.commuteWage, formatter: NumberFormatter())
                            .multilineTextAlignment(TextAlignment.trailing)
                            .keyboardType(.numberPad)
                        Text("円")
                            .foregroundColor(.secondary)
                    }
                }
            }
            Section {
                Button(action: {
                    self.showDeleteAlert = true
                }) {
                    HStack {
                        Spacer()
                        Text("バイトを削除")
                            .foregroundColor(.red)
                        Spacer()
                    }
                }
                .alert("\(editOtJob.name)を削除しますか？", isPresented: $showDeleteAlert) {
                    Button("削除", role: .destructive) {
                        context.delete(editOtJob)
                        dismiss()
                    }
                    Button("キャンセル", role: .cancel) {}
                }
            }
        }
        .navigationTitle(editOtJob.name)
        .navigationBarTitleDisplayMode(.inline)
        .onDisappear {
            if !editOtJob.name.isEmpty {
                try? context.save()
            }
        }
    }
}
