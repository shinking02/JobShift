import SwiftUI
import AppVersionMonitorSwiftUI

extension AppVersionMonitorStatus {
    func statusMessage() -> String {
        switch self {
        case .updateAvailable:
            return "There are updates available"
        case .updateUnavailable:
            return "You are using the latest version"
        case .failure:
            return "Failed to get the latest version"
        }
    }
}

struct AppInfoView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(AppState.self) private var appState
    @State private var appVersionStatus: AppVersionMonitorStatus?
    
    var body: some View {
        let info = Bundle.main.infoDictionary!
        let versionName = "\(info["CFBundleShortVersionString"]!)_\(info["CommitHash"]!)"
        HStack {
            Image(colorScheme == .light ? "github_light" : "github_dark")
                .resizable()
                .frame(width: 52, height: 52)
            Spacer()
            VStack {
                Text(appVersionStatus?.statusMessage() ?? "Checking for updates")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .appVersionMonitor(id: appState.appId) { status in
            appVersionStatus = status
            print(status)
        }
    }
}
