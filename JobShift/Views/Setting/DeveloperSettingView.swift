import SwiftUI

struct DeveloperSettingView: View {
    var body: some View {
        let keyList = UserDefaults.standard.dictionaryRepresentation()
            .filter { $0.key.starts(with: "JS_") }
            .sorted(by: { $0.key < $1.key })
        List {
            ForEach(keyList, id: \.key) { key, value in
                VStack(alignment: .leading) {
                    Text(key)
                    Text("\(value)")
                        .foregroundColor(.secondary)
                }
            }
        }
        .navigationTitle("開発者向け情報")
        .navigationBarTitleDisplayMode(.inline)
        .overlay {
            if keyList.isEmpty {
                ContentUnavailableView {
                    Label("No Storage Data", systemImage: "externaldrive.fill.badge.exclamationmark")
                } description: {
                    Text("UserDefaults data starting with  JS_ does not exist")
                }
            }
        }
    }
}
