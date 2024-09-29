import Foundation

extension Task where Success == Never, Failure == Never {
    static func sleep(seconds duration: TimeInterval) async throws {
        let delay = UInt64(duration * 1_000 * 1_000 * 1_000)
        try await Task.sleep(nanoseconds: delay)
    }
    
    static func sleep(millisecond duration: TimeInterval) async throws {
        let delay = UInt64(duration * 1_000 * 1_000)
        try await Task.sleep(nanoseconds: delay)
    }
    
    static func sleep(microseconds duration: TimeInterval) async throws {
        let delay = UInt64(duration * 1_000)
        try await Task.sleep(nanoseconds: delay)
    }
}
