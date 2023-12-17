import Foundation
import SwiftUI
import SwiftData

struct JobSettingView: View {
    @Environment(\.modelContext) private var context
    @Query private var jobs: [Job]
    @Query private var oneTimeJobs: [OneTimeJob]
    @State private var showingDialog = false
    @State private var showingAddJobView = false
    @State private var showingAddOneTimeJobView = false
    @State private var groupedOtJobs: [Int: [OneTimeJob]] = [:]
    @State private var openThisYearRow = false
    
    var body: some View {
        List {
            if !jobs.isEmpty {
                Section(header: Text("定期バイト")) {
                    ForEach(jobs.reversed()) { job in
                        NavigationLink(destination: JobEditView(editJob: job)) {
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
            if !oneTimeJobs.isEmpty {
                Section(header: Text("単発バイト")) {
                    ForEach(Array(groupedOtJobs.keys).sorted(by: >), id: \.self) { year in
                        DisclosureGroup(String(year) + "年") {
                            ForEach((groupedOtJobs[year] ?? []).sorted { $0.date > $1.date }, id: \.self) { job in
                                NavigationLink(destination: OTJobEditView(editOtJob: job)) {
                                    HStack {
                                        Text(job.name)
                                        Spacer()
                                        Text(getDateString(date: job.date))
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
        .sheet(isPresented: $showingAddJobView) {
            JobAddView()
        }
        .sheet(isPresented: $showingAddOneTimeJobView) {
            OTJobAddView()
        }
        .navigationTitle("バイト")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            updateGroupedOtJobs()
        }
        .onChange(of: showingAddOneTimeJobView) {
            updateGroupedOtJobs()
        }
        .toolbar{
            Button(action: {
                self.showingDialog = true
            }, label: {
                Image(systemName: "plus")
            })
            .confirmationDialog("", isPresented: $showingDialog, titleVisibility: .hidden) {
                Button("定期バイト") {
                    self.showingAddJobView = true
                }
                Button("単発バイト") {
                    self.showingAddOneTimeJobView = true
                }
                Button("キャンセル", role: .cancel) {}
            } message: {
                Text("追加するバイトの種類を選択してください")
            }
        }
    }
    private func updateGroupedOtJobs() {
        withAnimation {
            self.groupedOtJobs = Dictionary(grouping: self.oneTimeJobs) { (job: OneTimeJob) -> Int in
                let calendar = Calendar.current
                let year = calendar.component(.year, from: job.date)
                return year
            }
        }
    }
    private func getDateString(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "M月d日"
        return dateFormatter.string(from: date)
    }
}
