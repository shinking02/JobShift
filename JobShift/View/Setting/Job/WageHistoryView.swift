import SwiftUI
import Algorithms

struct WageHistoryView: View {
    @State private var showAddWageView = false
    @StateObject var viewModel: JobBaseViewModel
    
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
                Button(action: { showAddWageView = true }, label: {
                    Image(systemName: "plus")
                })
            }
        }
        .sheet(isPresented: $showAddWageView, onDismiss: viewModel.sortAndUpdateWages) {
            WageAddView(viewModel: viewModel)
        }
        .onAppear {
            viewModel.sortAndUpdateWages()
        }
        .navigationTitle("昇給履歴")
    }
}

struct WageAddView: View {
    @StateObject var viewModel: JobBaseViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            List {
                DatePicker("昇給日", selection: $viewModel.newWageDate, in: viewModel.startDate..., displayedComponents: .date)
                            .environment(\.locale, Locale(identifier: "ja_JP"))
                            .frame(height: 30)
                TextField("昇給後の時給(円)", text: $viewModel.newWageString)
                    .keyboardType(.numberPad)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("キャンセル") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("追加") {
                        viewModel.addNewWage()
                        dismiss()
                    }.disabled(viewModel.newWageValidateError)
                }
            }
            .navigationTitle("昇給履歴を追加")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
