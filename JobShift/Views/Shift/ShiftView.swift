import SwiftUI

struct ShiftView: View {
    @Environment(AppState.self) private var appState
    var body: some View {
        NavigationStack {
            List {
            }
            .navigationTitle("shift")
        }
    }
}
