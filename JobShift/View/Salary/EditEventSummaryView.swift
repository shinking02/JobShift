import Foundation
import SwiftData
import SwiftUI

struct EditEventSummaryView: View {
    @State var viewModel: EditEventSummaryViewModel
    @State var title: String
    var body: some View {
        List {
            Section(header: Text("メモ")) {
                TextField("30分遅刻", text: $viewModel.summary)
            }
            Section(header: Text("調整"), footer: Text("追加の給料を入力してください")) {
                TextField("1000", text: $viewModel.adjustString)
                    .keyboardType(.numberPad)
            }
        }
        .scrollDismissesKeyboard(.immediately)
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .onWillDisappear {
            viewModel.onDisappear()
        }
    }
}
