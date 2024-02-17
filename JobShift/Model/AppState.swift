import Foundation
import GoogleAPIClientForREST

final class AppState: ObservableObject {
    static let shared: AppState = .init()
    private init() {}
    
    @Published var user: User = User(email: "", imageUrl: "", name: "")
    @Published var isLoggedIn: Bool = false
    @Published var loginProcessed: Bool = false
    @Published var firstSyncProcessed: Bool = false
}

struct User {
    var email: String
    var imageUrl: String
    var name: String
}
