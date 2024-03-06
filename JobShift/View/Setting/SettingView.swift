import SwiftUI
import CachedAsyncImage

struct SettingView: View {
    @State var viewModel = SettingViewModel()
    
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
                        Text("カレンダー設定")
                    }
                    NavigationLink(destination: JobSettingView()) {
                        Text("バイト一覧")
                    }
                }
                Section {
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
                }
                Section {
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
