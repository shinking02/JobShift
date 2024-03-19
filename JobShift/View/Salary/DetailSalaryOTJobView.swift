import SwiftUI

struct DetailSalaryOTJobView: View {
    @State var viewModel: DetailSalaryOTJobViewModel
    
    var body: some View {
        List {
            Section {
                HStack {
                    Text("\(String(viewModel.year))年 \(viewModel.month != 0 ? "\(String(viewModel.month))月" : "")")
                        .bold()
                    Spacer()
                    VStack {
                        HStack {
                            Spacer()
                            ConfirmChip(isConfirmed: true)
                            Text(viewModel.confirmSalary)
                                .font(.title2.bold())
                            + Text(" 円")
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            Section {
                ForEach(viewModel.otJobs, id: \.self) { otJob in
                    NavigationLink(destination: OTJobEditView(viewModel: OTJobEditViewModel(otJob: otJob))) {
                        HStack {
                            Text(otJob.name)
                            Spacer()
                            Text(otJob.date.toMdString())
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
        .navigationTitle("単発バイト")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.onAppear()
        }
    }
}
