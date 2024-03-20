import SwiftUI
import CachedAsyncImage
import LicenseList
import SwiftData

struct SettingView: View {
    @State var viewModel = SettingViewModel()
    @Query var jobs: [Job]
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack {
                        CachedAsyncImage(url: URL(string: viewModel.appState.user.imageUrl)) { image in
                            image.resizable()
                               .clipShape(Circle())
                       } placeholder: {
                            ProgressView()
                       }
                       .frame(width: 50, height: 50)
                        VStack(alignment: .leading) {
                            Text(viewModel.appState.user.name)
                                .font(.title2)
                            Text(viewModel.appState.user.email)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.horizontal)
                    }
                }
                Section {
                    NavigationLink(destination: CalendarSettingView()) {
                        Text("カレンダー")
                    }
                    NavigationLink(destination: JobSettingView()) {
                        Text("バイト")
                    }
                }
                Section {
                    NavigationLink("ライセンス") {
                        LicenseListView()
                            .navigationTitle("ライセンス")
                            .navigationBarTitleDisplayMode(.inline)
                    }
                    Toggle("開発者モード", isOn: $viewModel.appState.isDevelopperMode)
                }
                if viewModel.appState.isDevelopperMode {
                    Section {
                        Button(action: {
                            viewModel.clearDataBase()
                        } ) {
                            Text("Clear DataBase")
                        }.disabled(viewModel.isClearedDataBase)
                        Button(action: {
                            viewModel.clearSyncToken()
                        } ) {
                            Text("Clear SyncTokens")
                        }.disabled(viewModel.isClearedSyncToken)
                        Button(action: {
                            viewModel.clearLastSeenOnboardingVersion()
                        } ) {
                            Text("Clear LastSeenOBVersion")
                        }.disabled(viewModel.isClearedLastSeenOnboardingVersion)
                    }
                    if !viewModel.appState.googleSyncToken.isEmpty {
                        Section(header: Text("SYNCTOKEN")) {
                            ForEach(viewModel.appState.googleSyncToken.sorted(by: >), id: \.key) { key, value in
                                Text(key)
                                    .lineLimit(1)
                                Text(value)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(1)
                                    .font(.caption2)
                            }
                        }
                    }
                    ForEach(jobs, id: \.id) { job in
                        Section(header: Text("\(job.name) new")) {
                            ForEach(job.newEventSummaries, id: \.self) { summary in
                                Text("\(summary.eventId)")
                                Text("\(summary.summary)")
                            }
                        }
                        Section(header: Text("\(job.name) old")) {
                            ForEach(job.eventSummaries.sorted(by: { $0.key < $1.key }), id: \.key) { key, value in
                                Text("\(key)")
                                Text("\(value)")
                            }
                        }
                    }
                }
                Section(footer: HStack {
                    Spacer()
                    Text("© 2024 Shin Kawakami")
                        .foregroundStyle(.secondary)
                    Spacer()
                }) {
                    HStack {
                        Spacer()
                        Button("サインアウト") {
                            viewModel.signOutButtonTapped()
                        }
                        .alert("サインアウトしますか？", isPresented: $viewModel.showLogoutAlert) {
                            Button("キャンセル", role: .cancel) {}
                            Button("サインアウト", role: .destructive) {
                                viewModel.signOut()
                            }
                        } message: {
                            Text("バイトのデータは失われません")
                        }
                        .foregroundColor(.red)
                        Spacer()
                    }
                }
            }
            .animation(.default, value: viewModel.appState.isDevelopperMode)
            .navigationTitle("設定")
        }
    }
}
