import SwiftData
import SwiftUI

struct JobSettingView: View {
    @Query(sort: \Job.order) private var jobs: [Job]
    @Query(sort: \OneTimeJob.date, order: .reverse) private var otJobs: [OneTimeJob]
    @Environment(\.editMode) var editMode
    @State private var isJobAddSheetPresented = false
    @State private var isOTJobAddSheetOresented = false
    @State private var expanded: Set<Int> = []
    
    var body: some View {
        NavigationStack {
            List {
                if !jobs.isEmpty {
                    Section(header: Text("バイト")) {
                        ForEach(jobs) { job in
                            NavigationLink(destination: JobEditView(job: job)) {
                                HStack {
                                    Image(systemName: "circle.fill")
                                        .font(.caption)
                                        .foregroundStyle(job.color.toColor())
                                    Text(job.name)
                                    Spacer()
                                }
                            }
                        }
                        .onMove { from, to in
                            jobMove(from, to)
                        }
                    }
                    .disabled(false)
                }
                if !otJobs.isEmpty {
                    Section(header: Text("単発バイト")) {
                        ForEach(Set(otJobs.map { $0.date.year }).sorted(by: >), id: \.self) { year in
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
                                ForEach(otJobs.filter { $0.date.year == year }) { otJob in
                                    NavigationLink(destination: OTJobEditView(otJob: otJob)) {
                                        HStack {
                                            Text(otJob.name)
                                            Spacer()
                                            Text(otJob.date.toString(.normal))
                                                .foregroundStyle(.secondary)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("バイト")
            .navigationBarTitleDisplayMode(.inline)
            .overlay {
                if jobs.isEmpty && otJobs.isEmpty {
                    ContentUnavailableView {
                        Label("バイトがありません", image: "custom.pencil.and.list.clipboard.badge.exclamationmark")
                    }
                }
            }
            .toolbar {
                if editMode?.wrappedValue == .active {
                    ToolbarItem(placement: .topBarTrailing) {
                        Menu {
                            Button {
                                isJobAddSheetPresented = true
                            } label: {
                                Label("バイト", systemImage: "clock.arrow.2.circlepath")
                            }
                            Button {
                                isOTJobAddSheetOresented = true
                            } label: {
                                Label("単発バイト", systemImage: "clock.badge")
                            }
                        } label: {
                            Image(systemName: "plus")
                        }
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    EditButton()
                }
                
            }
            .sheet(isPresented: $isJobAddSheetPresented) {
                JobAddView()
            }
            .sheet(isPresented: $isOTJobAddSheetOresented) {
                OTJobAddView()
            }
            .onAppear {
                let maxYear = otJobs.map { $0.date.year }.max()
                if let year = maxYear {
                    expanded.insert(year)
                }
            }
        }
    }
    private func jobMove(_ from: IndexSet, _ to: Int) {
        var tempJobs = self.jobs
        tempJobs.move(fromOffsets: from, toOffset: to)
        for i in 0..<tempJobs.count {
            jobs.first { $0.id == tempJobs[i].id }?.order = i
        }
    }
}
