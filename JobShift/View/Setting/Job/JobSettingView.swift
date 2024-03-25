import SwiftUI

struct JobSettingView: View {
    @State private var viewModel = JobSettingViewModel()
    @State private var expandedYears: Set<Int> = [Calendar.current.component(.year, from: Date())]
    
    var body: some View {
        List {
            if !viewModel.jobs.isEmpty {
                Section(header: Text("定期バイト")) {
                    ForEach(viewModel.jobs) { job in
                        NavigationLink(destination: JobEditView(viewModel: JobEditViewModel(job: job))) {
                            HStack {
                                Image(systemName: "circle.fill")
                                    .foregroundColor(job.color.getColor())
                                    .font(.caption)
                                Text(job.name)
                            }
                        }
                    }
                }
            }
            if !viewModel.groupedOtJobs.isEmpty {
                Section(header: Text("単発バイト")) {
                    ForEach(Array(viewModel.groupedOtJobs.keys).sorted(by: >), id: \.self) { year in
                        DisclosureGroup(String(year) + "年", isExpanded: Binding<Bool>(
                            get: { expandedYears.contains(year) },
                            set: { isExpanding in
                                if isExpanding {
                                    expandedYears.insert(year)
                                } else {
                                    expandedYears.remove(year)
                                }
                            }
                        )) {
                            ForEach((viewModel.groupedOtJobs[year] ?? []).sorted { $0.date > $1.date }, id: \.self) { job in
                                NavigationLink(destination: OTJobEditView(viewModel: OTJobEditViewModel(otJob: job))) {
                                    HStack {
                                        Text(job.name)
                                        Spacer()
                                        Text(job.date.toMdString())
                                            .font(.callout)
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        .toolbar {
            Button(action: {
                viewModel.jobPlusButtonTapped()
            }, label: {
                Image(systemName: "plus")
            })
            .confirmationDialog("", isPresented: $viewModel.showingJobTypeDialog, titleVisibility: .hidden) {
                Button("定期バイト") {
                    viewModel.addJobButtonTapped()
                }
                Button("単発バイト") {
                    viewModel.addOTJobButtonTapped()
                }
                Button("キャンセル", role: .cancel) {}
            } message: {
                Text("追加するバイトの種類を選択してください")
            }
        }
        .sheet(isPresented: $viewModel.showingAddJobView, onDismiss: {
            viewModel.onAppear()
        }, content: {
            JobAddView(viewModel: JobAddViewModel())
        })
        .sheet(isPresented: $viewModel.showingAddOTJobView, onDismiss: {
            viewModel.onAppear()
        }, content: {
            OTJobAddView(viewModel: OTJobAddViewModel())
        })
        .onAppear {
            viewModel.onAppear()
        }
        .navigationTitle("バイト")
        .navigationBarTitleDisplayMode(.inline)
    }
}
