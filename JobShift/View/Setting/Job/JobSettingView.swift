import SwiftUI

struct JobSettingView: View {
    @State private var viewModel = JobSettingViewModel()
    @State private var expandedYears: Set<Int> = [Calendar.current.component(.year, from: Date())]
    @State private var showingJobTypeDialog = false
    @State private var showingAddJobView = false
    @State private var showingAddOTJobView = false
    
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
                self.showingJobTypeDialog = true
            }, label: {
                Image(systemName: "plus")
            })
            .confirmationDialog("", isPresented: $showingJobTypeDialog, titleVisibility: .hidden) {
                Button("定期バイト") {
                    self.showingAddJobView = true
                }
                Button("単発バイト") {
                    self.showingAddOTJobView = true
                }
                Button("キャンセル", role: .cancel) {}
            } message: {
                Text("追加するバイトの種類を選択してください")
            }
        }
        .sheet(isPresented: $showingAddJobView, onDismiss: {
            viewModel.onAppear()
        }) {
            JobAddView(viewModel: JobAddViewModel())
        }
        .sheet(isPresented: $showingAddOTJobView, onDismiss: {
            viewModel.onAppear()
        }) {
            OTJobAddView(viewModel: OTJobAddViewModel())
        }
        .onAppear() {
            viewModel.onAppear()
        }
        .navigationTitle("バイト一覧")
        .navigationBarTitleDisplayMode(.inline)
    }
}
