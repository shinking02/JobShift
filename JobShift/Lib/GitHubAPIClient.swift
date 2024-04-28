import Foundation

struct Commit: Codable {
    let sha: String
    let node_id: String
}

class GitHubAPIClient {
    static let shared: GitHubAPIClient = .init()
    private let githubRepositoryURL = "https://api.github.com/repos/shinking02/JobShift/commits/main"
    private init() {}
    
    func fetchLatestCommitHash(short: Bool) async -> String? {
        do {
            guard let url = URL(string: githubRepositoryURL) else { return nil }
            let (data, response) = try await URLSession.shared.data(from: url)
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else { return nil }
            let decoder = JSONDecoder()
            let latestCommit = try decoder.decode(Commit.self, from: data)
            guard let latestCommitHash = latestCommit.sha as String? else { return nil }
            return short ? String(latestCommitHash.prefix(7)) : latestCommitHash
        } catch {
            print("ERROR: \(error.localizedDescription)")
            return nil
        }
    }
}
