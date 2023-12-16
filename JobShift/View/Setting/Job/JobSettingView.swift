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
    
    var body: some View {
        List {
            if !jobs.isEmpty {
                Section(header: Text("定期バイト")) {
                    
                }
            }
            if !oneTimeJobs.isEmpty {
                Section(header: Text("単発バイト")) {
                    
                }
            }
        }
        .sheet(isPresented: $showingAddJobView) {
            JobAddView()
        }
        .sheet(isPresented: $showingAddOneTimeJobView) {
            OneTimeJobAddView()
        }
        .navigationTitle("バイト")
        .navigationBarTitleDisplayMode(.inline)
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
}
