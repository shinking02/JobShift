import Foundation
import SwiftUI
import GoogleAPIClientForREST

struct EventEditView: View {
    @Environment(\.dismiss) var dismiss
    @Environment var eventStore: EventStore
    @State var event: GTLRCalendar_Event
    var body: some View {
        NavigationView {
            List {
                
            }
            .navigationTitle("イベントを編集")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("キャンセル") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("追加") {
                        dismiss()
                    }
                    
                }
            }
        }
    }
}
