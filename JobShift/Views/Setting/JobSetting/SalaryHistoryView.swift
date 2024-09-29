import SwiftUI

struct SalaryHistoryView: View {
    @Binding var salary: JobSalary
    @State private var expanded: Set<Int> = []
    @State private var salaryAddSheetPresented = false
    
    var body: some View {
        NavigationStack {
            List(Set(salary.histories.map { $0.year }).sorted(by: >), id: \.self) { year in
                DisclosureGroup(
                    String(year) + "年",
                    isExpanded: Binding<Bool>(
                        get: { expanded.contains(year) },
                        set: { isExpanding in
                            if isExpanding {
                                expanded.insert(year)
                            } else {
                                expanded.remove(year)
                            }
                        }
                    )
                ) {
                    ForEach($salary.histories.filter { $0.year == year }.sorted { $l, $r in l.month < r.month }) { $history in
                        NavigationLink {
                            SalaryEditView(
                                history: $history,
                                title: String(history.year) + "年" + String(history.month) + "月",
                                onDelete: {
                                    salary.histories.removeAll { $0.id == history.id }
                                }
                            )
                        } label: {
                            HStack {
                                Text(String(history.month) + "月")
                                Spacer()
                                Text("\(history.salary)円")
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }
            .navigationTitle("給与実績")
            .navigationBarTitleDisplayMode(.inline)
            .overlay {
                if salary.histories.isEmpty {
                    ContentUnavailableView {
                        Label("給与実績がありません", systemImage: "clock.badge.exclamationmark")
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        salaryAddSheetPresented = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(
                isPresented: $salaryAddSheetPresented,
                onDismiss: { controllDisclosureGroup() },
                content: {
                    SalaryAddSheetView(salary: $salary)
                        .presentationDetents([.medium])
                }
            )
            .onAppear {
                controllDisclosureGroup()
            }
        }
    }
    private func controllDisclosureGroup() {
        let maxYear = salary.histories.map { $0.year }.max()
        if let year = maxYear {
            expanded.insert(year)
        }
    }
}
