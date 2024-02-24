import SwiftUI

enum OTJobFocusField {
    case commuteWage
}

struct OTJobFormView: View {
    @Binding var name: String
    @Binding var salary: String
    @Binding var date: Date
    @Binding var isCommuteWage: Bool
    @Binding var commuteWage: String
    @Binding var summary: String
    @FocusState private var focusState : OTJobFocusField?
    
    var body: some View {
        Section(header: Text("名前"), footer:Text("バイト名を入力してください。名前によるGoogleカレンダーからの集計は行われません。")) {
            TextField("イベント設営", text: $name)
        }
        Section(header: Text("給料(円)")) {
            TextField("8000", text: $salary)
                .keyboardType(.numberPad)
        }
        Section {
            DatePicker("勤務日", selection: $date, displayedComponents: .date)
                .frame(height: 30)
                .environment(\.locale, Locale(identifier: "ja_JP"))
            Toggle("通勤手当", isOn: $isCommuteWage.animation())
            if isCommuteWage {
                TextField("往復料金(円)", text: $commuteWage)
                    .keyboardType(.numberPad)
                    .focused($focusState, equals: .commuteWage)
            }
        }
        .onChange(of: isCommuteWage) {
            if isCommuteWage {
                focusState = .commuteWage
            }
        }
        Section(header: Text("メモ")) {
            TextField("手渡し", text: $summary)
        }
    }
}
