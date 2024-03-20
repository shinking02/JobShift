import SwiftUI
import SwiftData

struct EditSalaryHistory: View {
    @Environment(\.modelContext) private var context
    @State var job: Job
    @State var year: Int
    @State var month: Int?
    @State private var openTargetYear = true
    @State private var yearGroupedHistories: [Int: [SalaryHistory]] = [:]
    @State private var showAddSalaryView = false
    @State private var expanded: Set<Int> = []
    
    var body: some View {
        List {
            ForEach(Array(yearGroupedHistories.keys).sorted(by: >), id: \.self) { year in
                DisclosureGroup(String(year) + "年", isExpanded: Binding<Bool>(
                    get: { expanded.contains(year) },
                    set: { isExpanding in
                        if isExpanding {
                            expanded.insert(year)
                        } else {
                            expanded.remove(year)
                        }
                    }
                )) {
                    if let yearHistories = yearGroupedHistories[year] {
                        let sortedHistories = yearHistories.sorted { $0.month < $1.month }
                        
                        ForEach(sortedHistories, id: \.self) { salary in
                            HStack {
                                Text("\(salary.month)月")
                                Spacer()
                                Text("\(salary.salary)円")
                            }
                        }
                        .onDelete { indexSet in
                            if let yearHistories = yearGroupedHistories[year] {
                                let sortedHistories = yearHistories.sorted { $0.month < $1.month }
                                
                                for index in indexSet {
                                    let salaryToDelete = sortedHistories[index]
                                    job.salaryHistories.removeAll { $0.year == salaryToDelete.year && $0.month == salaryToDelete.month }
                                }
                                yearGroupedHistories[year] = job.salaryHistories.filter { $0.year == year }
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle(job.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    self.showAddSalaryView = true
                }) {
                    Image(systemName: "plus")
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                EditButton()
            }
        }
        .sheet(isPresented: $showAddSalaryView, onDismiss: {
            self.yearGroupedHistories = Dictionary(grouping: job.salaryHistories, by: { $0.year })
        }){
            let month = self.month ?? Calendar.current.component(.month, from: Date())
            SalaryAddView(year: year, month: month, selectedJob: job)
        }
        .onAppear {
            self.yearGroupedHistories = Dictionary(grouping: job.salaryHistories, by: { $0.year })
            self.expanded.insert(year)
        }
    }
}
