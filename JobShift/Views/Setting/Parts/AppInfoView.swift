import Shimmer
import SwiftUI

enum BuildCommitStatus {
    case loading
    case latest
    case outdated
    case failed
    
    func statusText() -> String {
        switch self {
        case .loading:
            return "XXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
        case .latest:
            return "App is latest version"
        case .outdated:
            return "Branch has new commits"
        case .failed:
            return "Failed to check commit"
        }
    }
    
    @ViewBuilder
    func statusIcon() -> some View {
        switch self {
        case .latest:
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
        case .outdated:
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.orange)
        case .failed:
            Image(systemName: "xmark.octagon.fill")
                .foregroundColor(.red)
        default:
            EmptyView()
        }
    }
}

struct AppInfoView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.openURL) var openURL
    @State private var latestCommitHash: String = "undefined"
    @State private var buildCommitStatus: BuildCommitStatus = .loading
    private let buildCommitHash: String = Bundle.main.infoDictionary!["CommitHash"] as! String
    private let version: String = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
    private let build: String = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String
    
    var body: some View {
        Button {
            openURL(URL(string: "https://github.com/shinking02/JobShift/commits/main")!)
        } label: {
            HStack(alignment: .top) {
                Image(colorScheme == .light ? "github_light" : "github_dark")
                    .resizable()
                    .frame(width: 52, height: 52)
                Spacer()
                VStack(alignment: .leading) {
                    HStack {
                        Text(buildCommitStatus.statusText())
                        buildCommitStatus.statusIcon()
                    }
                    .font(.headline)
                    .foregroundStyle(.primary)
                    Text("BuildCommit: \(buildCommitHash) (Latest: \(latestCommitHash))")
                    Text("Version: \(version)(\(build))")
                }
                .font(.caption)
                .foregroundStyle(.secondary)
                .redacted(reason: buildCommitStatus == .loading ? .placeholder : [])
                .shimmering(active: buildCommitStatus == .loading)
                Spacer()
            }
        }
        .foregroundStyle(.primary)
        .onAppear {
            if buildCommitStatus == .loading {
                Task { await checkLatestCommit() }
            }
        }
    }
    private func checkLatestCommit() async {
        let commitHash = await GitHubAPIClient.shared.fetchLatestCommitHash(short: true)
        withAnimation {
            if let commitHash = commitHash {
                latestCommitHash = commitHash
                buildCommitStatus = commitHash == buildCommitHash ? .latest : .outdated
            } else {
                buildCommitStatus = .failed
            }
        }
    }
}
