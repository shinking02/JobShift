import Foundation

struct Commit: Codable {
    let sha: String
    let node_id: String
}

class GitHubAPIClient {
    static let shared: GitHubAPIClient = .init()
    private let githubRepositoryURL = "https://api.github.com/repos/shinking02/JobShift"
    private init() {}
    
    func fetchLatestCommitHash(short: Bool) async -> String? {
        do {
            guard let url = URL(string: "\(githubRepositoryURL)/commits/main") else { return nil }
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
    
    func submitIssue(title: String, description: String, selectedLabels: Set<String>, completion: @escaping (Result<String, Error>) -> Void) {
        guard !title.isEmpty, !description.isEmpty else {
            completion(.failure(NSError(domain: "", code: 400, userInfo: [NSLocalizedDescriptionKey: "タイトルと内容は必須です"])))
            return
        }

        let url = URL(string: "\(githubRepositoryURL)/issues")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("token \(APIKeyManager.shared.apiKey(for: "GITHUB_API_KEY") ?? "")", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let issue = [
            "title": title,
            "body": description,
            "labels": Array(selectedLabels)
        ] as [String: Any]

        do {
            let jsonData = try JSONSerialization.data(withJSONObject: issue)
            let task = URLSession.shared.uploadTask(with: request, from: jsonData) { data, response, error in
                guard let data = data, error == nil else {
                    completion(.failure(error ?? NSError(domain: "", code: 500, userInfo: [NSLocalizedDescriptionKey: "Unknown error"])))
                    return
                }

                let httpResponse = response as! HTTPURLResponse
                if httpResponse.statusCode == 201,
                   let responseData = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let issueURL = responseData["html_url"] as? String {
                    completion(.success(issueURL))
                } else {
                    let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
                    completion(.failure(NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: errorMessage])))
                }
            }
            task.resume()
        } catch {
            completion(.failure(error))
        }
    }
}
