import Foundation

class UserState: ObservableObject {
    @Published var email: String = ""
    @Published var imageURL: String = ""
    @Published var isLoggedIn: Bool = false
}
