import Foundation

class APIKeyManager {
    static let shared = APIKeyManager()
    
    private init() {}

    func apiKey(for service: String) -> String? {
        guard let keys = Bundle.main.infoDictionary?["APIKeys"] as? [String: Any],
              let key = keys[service] as? String else {
            return nil
        }
        return key
    }
}
