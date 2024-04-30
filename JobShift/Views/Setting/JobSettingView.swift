import SwiftData
import SwiftUI

struct JobSettingView: View {
    @Query(sort: \Job.order) private var jobs: [Job]
    @Query private var otJobs: [OneTimeJob]
    @State private var isJobAddSheetPresented = false
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach(jobs) { job in
                        HStack {
                            Image(systemName: "circle.fill")
                                .font(.caption)
                                .foregroundStyle(job.color.toColor())
                            Text(job.name)
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
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button {
                            isJobAddSheetPresented = true
                        } label: {
                            Label("定期バイト", systemImage: "clock.arrow.2.circlepath")
                        }
                        Button {
                            // nop
                        } label: {
                            Label("単発バイト", systemImage: "clock.badge")
                        }
                    } label: {
                        Image(systemName: "plus")
                    }
                    
                }
            }
            .sheet(isPresented: $isJobAddSheetPresented) {
                JobAddView()
            }
        }
    }
}
