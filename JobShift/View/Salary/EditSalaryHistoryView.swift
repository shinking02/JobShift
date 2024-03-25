import SwiftUI

struct EditSalaryHistoryView: View {
    @State var viewModel: EditSalaryHistoryViewModel
    @State private var showingAddSalarySheet = false
    
    var body: some View {
        List {
            ForEach(Array(viewModel.yearGroupedHistories.keys).sorted(by: >), id: \.self) { year in
                DisclosureGroup(String(year) + "年", isExpanded: Binding<Bool>(
                    get: { viewModel.expanded.contains(year) },
                    set: { isExpanding in
                        if isExpanding {
                            viewModel.expanded.insert(year)
                        } else {
                            viewModel.expanded.remove(year)
                        }
                    }
                )) {
                    if let yearHistories = viewModel.yearGroupedHistories[year] {
                        let sortedHistories = yearHistories.sorted { $0.month < $1.month }
                        
                        ForEach(sortedHistories, id: \.self) { salary in
                            HStack {
                                Text("\(salary.month)月")
                                Spacer()
                                Text("\(salary.salary)円")
                            }
                        }
                        .onDelete { indexSet in
                            viewModel.deleteSalary(indexSet: indexSet, year: year)
                        }
                    }
                }
            }
        }
        .navigationTitle("給与実績を編集")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    showingAddSalarySheet = true
                }, label: {
                    Image(systemName: "plus")
                })
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                EditButton()
            }
        }
        .sheet(isPresented: $showingAddSalarySheet, onDismiss: {
            viewModel.onAppear()
        }, content: {
            SalaryAddSheetView(viewModel: SalaryAddSheetViewModel(job: viewModel.job))
        })
        .onAppear {
            viewModel.onAppear()
        }
        .onWillDisappear {
            viewModel.onDisAppear()
        }
    }
}
