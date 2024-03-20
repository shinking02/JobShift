import Foundation
import SwiftUI

struct OTJobAddView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) var dismiss
    @Bindable var newOtJob = OneTimeJob()
    @State private var showAlert = false
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("名前"), footer:Text("バイト名を入力してください。名前によるGoogleカレンダーからの集計は行われません。")) {
                    TextField("", text: $newOtJob.name)
                }
                Section(header: Text("メモ")) {
                    TextField("", text: $newOtJob.summary)
                }
                Section {
                    DatePicker("勤務日", selection: $newOtJob.date, displayedComponents: .date)
                        .frame(height: 30)
                        .environment(\.locale, Locale(identifier: "ja_JP"))
                    HStack {
                        Text("給料")
                        TextField("", value: $newOtJob.salary, formatter: NumberFormatter())
                            .multilineTextAlignment(TextAlignment.trailing)
                            .keyboardType(.numberPad)
                        Text("円")
                            .foregroundColor(.secondary)
                    }
                    Toggle("通勤手当", isOn: $newOtJob.isCommuteWage.animation())
                    if newOtJob.isCommuteWage {
                        HStack {
                            Text("往復料金")
                            TextField("", value: $newOtJob.commuteWage, formatter: NumberFormatter())
                                .multilineTextAlignment(TextAlignment.trailing)
                                .keyboardType(.numberPad)
                            Text("円")
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("新規単発バイト")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("キャンセル") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("追加") {
                        if newOtJob.name.isEmpty {
                            self.showAlert = true
                        } else {
                            context.insert(newOtJob)
                            dismiss()
                        }
                    }
                    .alert("エラー", isPresented: $showAlert) {
                        Button("OK") {
                            self.showAlert = false
                        }
                    } message: {
                        Text("名前を入力してください")
                    }
                }
            }
        }
    }
}
