import Algorithms
import SwiftUI

struct WageHistoryView: View {
    @State var viewModel: JobFormViewModel
    
    var body: some View {
        List {
            ForEach(viewModel.wages.indexed(), id: \.element) { index, wage in
                HStack {
                    VStack(alignment: .leading) {
                        Text("\(wage.start.toYYYYMdString())〜")
                        Text(wage.end.toYYYYMdString())
                    }
                    .foregroundStyle(.secondary)
                    .font(.caption)
                    Spacer()
                    Text("\(viewModel.isDailyWage ? wage.dailyWage : wage.hourlyWage)")
                        .font(.title2)
                        .bold()
                    + Text(" 円")
                        .bold()
                        .foregroundColor(.secondary)
                }
                .deleteDisabled(index == 0)
            }
            .onDelete(perform: { index in
                viewModel.deleteWage(at: index)
            })
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { viewModel.wagePlusButtonTapped() }, label: {
                    Image(systemName: "plus")
                })
            }
        }
        .sheet(isPresented: $viewModel.showAddWageView, onDismiss: viewModel.addSheetDismiss) {
            WageAddView(viewModel: viewModel)
        }
        .onAppear {
            viewModel.addViewOnAppear()
        }
        .navigationTitle("昇給履歴")
    }
}
