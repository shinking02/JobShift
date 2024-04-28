import NotificationPermission
import PermissionsKit
import SwiftUI

struct NotificationSettingView: View {
    @Environment(\.openURL) var openURL
    @Environment(\.scenePhase) private var scenePhase
    @State private var enableSalaryPaymentNotification = false
    @State private var notificationPermissionStatus: Permission.Status = .notDetermined
    
    var body: some View {
        List {
            Section(footer:
                Text(
                    """
                          許可しない場合は該当の機能が正しく動作しない場合があります。
                          権限の拒否後に許可したい場合は、設定アプリから対象の権限を変更してください。
                          """
                )
            ) {
                HStack {
                    Image(systemName: "bell.fill")
                        .foregroundStyle(Color.accentColor)
                        .font(.system(size: 40))
                        .frame(width: 40)
                        .padding(.horizontal, 5)
                    VStack(alignment: .leading) {
                        Text("通知")
                            .font(.system(size: 20))
                            .bold()
                        Text("給料日のお知らせを通知します")
                            .font(.system(size: 12.86))
                            .foregroundStyle(.secondary)
                    }
                    .padding(.horizontal, 3)
                    Spacer()
                    AllowStatusView(status: $notificationPermissionStatus)
                }
                Button {
                    openURL(URL(string: UIApplication.openSettingsURLString)!)
                } label: {
                    Text("設定アプリを開く")
                }
            }
            Section(footer:
                Text("支払われる給料がある場合に通知されます")
            ) {
                Toggle(isOn: $enableSalaryPaymentNotification) {
                    Text("給料日に通知")
                        .onChange(of: enableSalaryPaymentNotification) {
                            if notificationPermissionStatus == .authorized {
                                Storage.setEnableSalaryPaymentNotification(enableSalaryPaymentNotification)
                            }
                        }
                        .foregroundStyle(notificationPermissionStatus == .authorized ? .primary : .secondary)
                }
                .disabled(notificationPermissionStatus != .authorized)
            }
        }
        .onAppear {
            Task.detached { @MainActor in
                checkNotificationPermission()
            }
        }
        .onChange(of: scenePhase) {
            if scenePhase == .active {
                checkNotificationPermission()
            }
        }
        .navigationTitle("通知")
        .navigationBarTitleDisplayMode(.inline)
    }
    private func checkNotificationPermission() {
        withAnimation {
            if Permission.notification.status == .notDetermined {
                Permission.notification.request {
                    notificationPermissionStatus = Permission.notification.status
                }
            } else {
                notificationPermissionStatus = Permission.notification.status
            }
            enableSalaryPaymentNotification = Storage.getEnableSalaryPaymentNotification() && notificationPermissionStatus == .authorized
        }
    }
}
