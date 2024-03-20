import SwiftUI

struct SalaryAddSheetView: View {
    @Environment(\.dismiss) var dismiss
    @State var viewModel: SalaryAddSheetViewModel
    @State var pickerIsPresented = false
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    Picker("バイト", selection: $viewModel.jobSelection) {
                        ForEach(viewModel.jobs, id: \.self) { job in
                            Text(job.name)
                        }
                    }
                }
                Section(footer: viewModel.existSalaryError
                        ? Text("\(viewModel.jobSelection.name)には\(String(viewModel.yearMonth.year))年\(String(viewModel.yearMonth.month))月の給料が登録済みです")
                            .foregroundStyle(.red)
                        : nil
                ) {
                    Button {
                        withAnimation {
                            pickerIsPresented.toggle()
                        }
                    } label: {
                        HStack {
                            Text("年月")
                                .foregroundColor(.primary)
                            Spacer()
                            Text("\(String(viewModel.yearMonth.year))年 \(String(viewModel.yearMonth.month))月")
                                .foregroundColor(pickerIsPresented ? .blue : .secondary)
                            Image(systemName: "chevron.down")
                                .rotationEffect(.degrees(pickerIsPresented ? 0 : -90))
                                .foregroundColor(pickerIsPresented ? .blue : .secondary)
                        }
                    }
                    if pickerIsPresented {
                        CustomDatePicker(selectedYear: $viewModel.yearMonth.year, selectedMonth: $viewModel.yearMonth.month, showMonth: true)
                    }
                }
                Section(header: Text("給料"), footer: Text("交通費を含めてください")) {
                    TextField("給料(円)", text: $viewModel.salaryString)
                        .keyboardType(.numberPad)
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("キャンセル") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("追加") {
                        viewModel.addButtonTapped()
                        dismiss()
                    }
                    .disabled(viewModel.existSalaryError || viewModel.salaryError)
                }
            }
            .scrollDismissesKeyboard(.immediately)
            .navigationTitle("給料実績の追加")
            .navigationBarTitleDisplayMode(.inline)
            .scrollDismissesKeyboard(.immediately)
            .onAppear {
                viewModel.onAppear()
            }
        }
    }
}
