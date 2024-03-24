import Charts
import SwiftUI

struct SalaryChartView: View {
    @State var viewModel: SalaryChartViewModel
    @Binding var year: Int
    @Binding var month: Int
    @Binding var includeCommuteWage: Bool
    @Binding var showSalaryAddSheet: Bool
    @State private var selectedEntry: ChartEntry?
    @State private var selectedCount: Int?
    
    var body: some View {
        List {
            Chart(viewModel.chartData, id: \.self) { entry in
                SectorMark(
                    angle: .value("", entry.salary),
                    innerRadius: .ratio(0.8),
                    angularInset: 1.5
                )
                .cornerRadius(5)
                .foregroundStyle(entry.color)
                .opacity(selectedEntry == nil ? 1.0 : (selectedEntry == entry ? 1.0 : 0.5))
            }
            .frame(height: 230)
            .listRowBackground(Color.clear)
            .chartAngleSelection(value: $selectedCount)
            .onChange(of: selectedCount) { oldValue, newValue in
                if let newValue {
                    selectedEntry = viewModel.findSelectedSector(value: newValue)
                } else {
                    selectedEntry = nil
                }
            }
            .onChange(of: selectedEntry) {
                UISelectionFeedbackGenerator().selectionChanged()
            }
            .chartBackground { chartProxy in
                GeometryReader { geometry in
                    let frame = geometry[chartProxy.plotFrame!]
                    VStack {
                        if let selectedEntry = selectedEntry {
                            Text(selectedEntry.label)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text("\(selectedEntry.salary)円")
                                .font(.title2.bold())
                        } else {
                            HStack {
                                Text("\(abs(viewModel.allSalary - viewModel.lastAllSalary))円")
                                Image(systemName: viewModel.totalImageName)
                                    .frame(width: 3)
                            }
                            .font(.caption)
                            .foregroundStyle(viewModel.totalColor)
                            Text("\(viewModel.allSalary)円")
                                .font(.title2.bold())
                        }
                    }
                    .contentTransition(.numericText(countsDown: true))
                    .position(x: frame.midX, y: frame.midY)
                }
            }
            ForEach(viewModel.chartData, id: \.self) { entry in
                SalaryRowView(
                    entry: entry,
                    includeCommuteWage: $includeCommuteWage,
                    year: $year,
                    month: $month
                )
                .environment(viewModel)
            }
        }
        .sheet(isPresented: $showSalaryAddSheet, onDismiss: {
            viewModel.update(includeCommuteWage)
        }, content: {
            SalaryAddSheetView(viewModel: SalaryAddSheetViewModel(job: nil))
        })
        .onAppear {
            viewModel.update(includeCommuteWage)
        }
        .onChange(of: includeCommuteWage) {
            viewModel.update(includeCommuteWage)
        }
    }
}
