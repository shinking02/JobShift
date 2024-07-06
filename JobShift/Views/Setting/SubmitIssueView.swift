import SwiftUI

struct SubmitIssueView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var title: String = ""
    @State private var description: String = ""
    @State private var selectedLabels: Set<String> = []
    @State private var showingErrorAlert = false
    @State private var showingSuccessAlert = false
    @State private var alertMessage = ""

    let labels = ["バグ", "新機能", "改善"]

    var body: some View {
        NavigationStack {
            List(selection: $selectedLabels) {
                Section(header: Text("要望内容")) {
                    TextField("タイトルを入力してください", text: $title)
                    ZStack(alignment: .topLeading) {
                        TextEditor(text: $description)
                            .padding(.horizontal, -4)
                            .frame(minHeight: 200)
                        if description.isEmpty {
                            Text("内容を詳細に入力してください") .foregroundColor(Color(uiColor: .placeholderText))
                                .padding(.vertical, 8)
                                .allowsHitTesting(false)
                        }
                    }
                }
                Section(header: Text("ラベル")) {
                    ForEach(labels, id: \.self) { label in
                        Text(label)
                    }
                }
            }
            .environment(\.editMode, .constant(.active))
            .navigationBarTitle("要望")
            .navigationBarTitleDisplayMode(.inline)
            .scrollDismissesKeyboard(.immediately)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("送信") { submitIssue() }
                        .alert(isPresented: $showingErrorAlert) {
                            Alert(title: Text("エラー"), message: Text(alertMessage), dismissButton: .default(Text("閉じる")))
                        }
                        .alert("送信されました", isPresented: $showingSuccessAlert) {
                            Button {
                                showingSuccessAlert = false
                                dismiss()
                            } label: {
                                Text("閉じる")
                            }
                            Button {
                                UIApplication.shared.open(URL(string: alertMessage)!)
                                dismiss()
                            } label: {
                                Text("Issueを見る")
                            }
                        }
                }
            }
        }
    }

    func submitIssue() {
        GitHubAPIClient.shared.submitIssue(title: title, description: description, selectedLabels: selectedLabels) { result in
            switch result {
            case .success(let issueURL):
                alertMessage = issueURL
                showingSuccessAlert = true
            case .failure(let error):
                alertMessage = error.localizedDescription
                showingErrorAlert = true
            }
        }
    }
}
