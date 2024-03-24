import SwiftUI

enum OTJobFocusField {
    case commuteWage
}

struct OTJobFormView: View {
    @Bindable var viewModel: OTJobFormViewModel
    @FocusState private var focusState: OTJobFocusField?
    
    var body: some View {
        Section(header: Text("名前"), footer: Text("バイト名を入力してください。名前によるGoogleカレンダーからの集計は行われません。")) {
            TextField("イベント設営", text: $viewModel.name)
        }
        Section(header: Text("給料(円)")) {
            TextField("8000", text: $viewModel.salaryString)
                .keyboardType(.numberPad)
        }
        Section {
            DatePicker("勤務日", selection: $viewModel.date, displayedComponents: .date)
                .frame(height: 30)
                .environment(\.locale, Locale(identifier: "ja_JP"))
            Toggle("通勤手当", isOn: $viewModel.isCommuteWage.animation())
            if viewModel.isCommuteWage {
                TextField("往復料金(円)", text: $viewModel.commuteWageString)
                    .keyboardType(.numberPad)
                    .focused($focusState, equals: .commuteWage)
            }
        }
        .onChange(of: viewModel.isCommuteWage) {
            if viewModel.isCommuteWage {
                focusState = .commuteWage
            }
        }
        Section(header: Text("メモ")) {
            TextField("手渡し", text: $viewModel.summary)
        }
    }
}
