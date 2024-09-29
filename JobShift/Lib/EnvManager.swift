import Foundation

enum LoadEnvError: Error {
    case FileNotFound
}

struct LoadEnv {

    init(fileAt path: String = "\(FileManager.default.currentDirectoryPath)/.env") throws {
        guard let envPath = Bundle.main.path(forResource: ".env", ofType: nil),
              let envData = FileManager.default.contents(atPath: envPath),
              let envString = String(data: envData, encoding: .utf8) else {
            throw LoadEnvError.FileNotFound
        }
        envString
            .split(whereSeparator: ["\n", "\r\n"].contains)
            .map(String.init)
            .forEach { line in
                let parts = line
                    .split(separator: "=", maxSplits: 1)
                    .map(String.init)
                setenv(parts[0], parts[1], 1)
            }
    }

    func value(_ key: String, _ default: String? = nil) -> String? {
        guard let value = getenv(key) else { return nil }
        return String(validatingUTF8: value)
    }
}
