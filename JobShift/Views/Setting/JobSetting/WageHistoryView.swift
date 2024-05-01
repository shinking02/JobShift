import SwiftUI

struct WageHistoryView: View {
    @Binding var wages: [JobWage]
    @State private var addSheetIsPresented = false
    
    var body: some View {
        NavigationStack {
            List($wages.sorted(by: { $l, $r in
                    return l.start < r.start
            })) { $wage in
                NavigationLink {
                    WageEditView(
                        wage: $wage,
                        canDelete: wages.count > 1,
                        onDelete: {
                            wages.removeAll(where: { $0.id == wage.id })
                        }
                    )
                } label: {
                    HStack {
                        Text(wage.start == .distantPast ? "入社" : wage.start.toString(.YYYYMD)) + Text("〜")
                        Spacer()
                        Text("\(wage.wage)円")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("基本給")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        addSheetIsPresented = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $addSheetIsPresented) {
                WageAddSheetView(wages: $wages)
                    .presentationDetents([.medium])
            }
        }
    }
}
