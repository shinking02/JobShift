import SwiftUI

struct SettingView: View {
    @ObservedObject var viewModel = SettingViewModel()
    @State var appState: AppState = AppState.shared
    @State private var showLogoutAlert: Bool = false
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    HStack {
                        AsyncImage(url: URL(string: appState.user.imageUrl)) { image in
                            image.resizable()
                               .clipShape(Circle())
                       } placeholder: {
                           Image(systemName: "person.crop.circle")
                               .resizable()
                       }
                       .frame(width: 50, height: 50)
                        VStack(alignment: .leading) {
                            Text(appState.user.name)
                                .font(.title2)
                            Text(appState.user.email)
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
                    Toggle("開発者モード", isOn: $viewModel.isDevelopperMode.animation())
                        .onChange(of: viewModel.isDevelopperMode) {
                            viewModel.handleChangeDevelopperMode()
                        }
                }
                if viewModel.isDevelopperMode {
                    if !viewModel.syncTokens.isEmpty {
                        Section(header: Text("SYNCTOKEN")) {
                            ForEach(viewModel.syncTokens.sorted(by: >), id: \.key) { key, value in
                                Text(key)
                                    .lineLimit(1)
                                Text(value)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(1)
                                    .font(.caption2)
                            }
                        }
                    }
                    Section {
                        Button(action: {
                            viewModel.clearDataBase()
                        } ) {
                            Text("Clear DataBase")
                        }.disabled(viewModel.isCleardDataBase)
                        Button(action: {
                            viewModel.clearSyncTokens()
                        } ) {
                            Text("Clear SyncTokens")
                        }.disabled(viewModel.isCleardSyncTokens)
                    }
                }
                Section {
                    HStack {
                        Spacer()
                        Button("サインアウト") {
                            showLogoutAlert = true
                        }
                        .alert("サインアウトしますか？", isPresented: $showLogoutAlert) {
                            Button("キャンセル", role: .cancel) {}
                            Button("サインアウト", role: .destructive) {
                                viewModel.signOut(appState: appState)
                            }
                        } message: {
                            Text("バイトのデータは失われません")
                        }
                        .foregroundColor(.red)
                        Spacer()
                    }
                }
            }
            .navigationTitle("設定")
        }
    }
}
