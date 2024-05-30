import RealmSwift
import SwiftUI

struct RealmDataBaseView: View {
    @State private var searchText = ""
    @ObservedResults(Event.self, sortDescriptor: SortDescriptor(keyPath: "start", ascending: false)) private var events

    private var searchedEvents: Results<Event> {
        if searchText.isEmpty {
            events
        } else {
            events.where({ $0.summary.contains(searchText) })
        }
    }
    
    var body: some View {
        List {
            ForEach(searchedEvents) { event in
                VStack(alignment: .leading) {
                    Text("\(event.summary)\(event.isAllDay ? " (All Day)" : "")")
                    Group {
                        Text("\(event.start)")
                        Text("\(event.end)")
                    }
                        .foregroundColor(.secondary)
                        .font(.caption)
                }
            }
        }
        .searchable(text: $searchText)
        .navigationTitle("RealmDataBase")
        .navigationBarTitleDisplayMode(.inline)
        .scrollDismissesKeyboard(.immediately)
        .overlay {
            if events.isEmpty {
                ContentUnavailableView {
                    Label("No Realm Data", systemImage: "externaldrive.badge.exclamationmark")
                } description: {
                    Text("Realm Database <Event> is empty")
                }
            }
        }
    }
}
