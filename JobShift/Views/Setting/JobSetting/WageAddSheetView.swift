import SwiftUI

struct WageAddSheetView: View {
    @Binding var wages: [JobWage]
    @Environment(\.dismiss) private var dismiss
    @State private var selectedDate = Date()
    @State private var wage = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section(
                    footer: Text("基本給の適用が開始される日付です。")
                ) {
                    DatePicker("開始日", selection: $selectedDate, displayedComponents: [.date])
                }
                Section(
                    footer: Text("時給・日給を入力してください。")
                ) {
                    TextField("金額", text: $wage)
                        .keyboardType(.numberPad)
                }
            }
            .navigationTitle("基本給を追加")
            .navigationBarTitleDisplayMode(.inline)
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
                        wages.append(JobWage(start: selectedDate, wage: Int(wage) ?? 0))
                        wages.sort(by: { $0.start < $1.start })
                        dismiss()
                    } label: {
                        Text("追加")
                    }
                    .disabled(wage.isEmpty)
                }
            }
        }
    }
}
