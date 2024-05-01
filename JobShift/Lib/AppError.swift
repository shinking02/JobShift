import Foundation

enum AppError: LocalizedError {
    enum Signin: LocalizedError {
        case failedRestorePreviousSignIn
        case userNotFound
        case failedSignIn
        
        var errorDescription: String? {
            switch self {
            case .failedRestorePreviousSignIn:
                return "Failed to restore previous sign in"
            case .userNotFound:
                return "User is not found"
            case .failedSignIn:
                return "Failed to sign in"
            }
        }
    }
    enum View: LocalizedError {
        case notFoundPresentingViewController
        
        var errorDescription: String? {
            switch self {
            case .notFoundPresentingViewController:
                return "Not found presenting view controller"
            }
        }
    }
    enum CalendarManager: LocalizedError {
        case initalizeFailed
        case failedGetCalendars
        
        var errorDescription: String? {
            switch self {
            case .initalizeFailed:
                return "Failed to initalize CalendarManager"
            case .failedGetCalendars:
                return "Failed to get calendars"
            }
        }
    }
    
    case signin(_ detail: Signin)
    case view(_ detail: View)
    case calendarManager(_ detail: CalendarManager)
    
    var errorDescription: String? {
        switch self {
        case .signin(let detail):
            return detail.errorDescription
        case .view(let detail):
            return detail.errorDescription
        case .calendarManager(let detail):
            return detail.errorDescription
        }
    }
}
