import CachedAsyncImage
import SwiftUI

struct ProfileSheetView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AppState.self) private var appState
    @State private var showSignOutAlert = false
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    VStack(alignment: .center) {
                        CachedAsyncImage(url: appState.user?.profile?.imageURL(withDimension: 200)) { image in
                            image.resizable()
                                .clipShape(Circle())
                        } placeholder: {
                            ProgressView()
                        }
                        .frame(width: 140, height: 140)
                        .shadow(radius: 8)
                        .padding()
                        Text(appState.user?.profile?.name ?? "No Name")
                            .font(.title.bold())
                        Text(appState.user?.profile?.email ?? "No Email")
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .listRowBackground(Color.clear)
                }
                Section {
                    Button {
                        showSignOutAlert = true
                    } label: {
                        Text("サインアウト")
                            .frame(maxWidth: .infinity, alignment: .center)
                            .foregroundStyle(.red)
                    }
                    .alert("サインアウトしますか？", isPresented: $showSignOutAlert) {
                        Button("キャンセル", role: .cancel) {}
                        Button("サインアウト", role: .destructive) {
                            GoogleSignInManager.signOut()
                            dismiss()
                        }
                    } message: {
                        Text("バイトのデータは失われません")
                    }
                    .foregroundColor(.red)
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Text("完了")
                            .bold()
                    }
                }
            }
            .navigationTitle("プロフィール")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
