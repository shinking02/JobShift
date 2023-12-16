import Foundation
import SwiftUI

struct WageAddView : View {
    @Environment(\.dismiss) var dismiss
    @Bindable var job: Job
    var body: some View {
        NavigationView {
            List {
                Text("WageAddView")
            }
            .navigationTitle("昇給履歴の追加")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("キャンセル") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("追加") {
                        
                    }
                }
            }
        }
    }
}
