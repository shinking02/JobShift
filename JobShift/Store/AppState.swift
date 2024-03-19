import Observation
import Foundation

enum UserDefaultsKeys {
    static let lastSyncedEmail = "LAST_SYNCED_EMAIL"
    static let isShowOnlyJobEvent = "IS_SHOW_ONLY_JOBEVENT"
    static let googleSyncToken = "GOOGLE_SYNC_TOKEN"
    static let isDevelopperMode = "IS_DEVELOPPER_MODE"
    static let userCalendars = "USER_CALENDARS"
    static let lastSeenOnboardingVersion = "LAST_SEEN_ONBOARDING_VERSION"
    static let defaultCalendar = "DEFAULT_CALENDAR"
}

@Observable final class UserCalendar: Codable, Hashable {
    var id: String
    var name: String
    var isActive: Bool
    init(id: String, name: String, isActive: Bool) {
        self.id = id
        self.name = name
        self.isActive = isActive
    }
    static func == (lhs: UserCalendar, rhs: UserCalendar) -> Bool {
        lhs.id == rhs.id
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

struct User {
    var email: String
    var imageUrl: String
    var name: String
}

@Observable final class AppState {
    static let shared = AppState()
    private init() {}

    var lastSyncedEmail: String {
        get { UserDefaults.standard.string(forKey: UserDefaultsKeys.lastSyncedEmail) ?? "" }
        set { UserDefaults.standard.setValue(newValue, forKey: UserDefaultsKeys.lastSyncedEmail) }
    }
    var isShowOnlyJobEvent: Bool {
        get { UserDefaults.standard.bool(forKey: UserDefaultsKeys.isShowOnlyJobEvent) }
        set { UserDefaults.standard.set(newValue, forKey: UserDefaultsKeys.isShowOnlyJobEvent) }
    }
    var googleSyncToken: [String: String] {
        get { UserDefaults.standard.dictionary(forKey: UserDefaultsKeys.googleSyncToken) as? [String: String] ?? [:] }
        set { UserDefaults.standard.set(newValue, forKey: UserDefaultsKeys.googleSyncToken) }
    }
    var isDevelopperMode: Bool {
        get { UserDefaults.standard.bool(forKey: UserDefaultsKeys.isDevelopperMode) }
        set { UserDefaults.standard.set(newValue, forKey: UserDefaultsKeys.isDevelopperMode) }
    }
    var userCalendars: [UserCalendar] {
        get {
            let jsonDecoder = JSONDecoder()
            guard let data = UserDefaults.standard.data(forKey: UserDefaultsKeys.userCalendars),
                  let userCalendars = try? jsonDecoder.decode([UserCalendar].self, from: data) else {
                return []
            }
            return userCalendars
        }
        set {
            let jsonEncoder = JSONEncoder()
            guard let data = try? jsonEncoder.encode(newValue) else { return }
            UserDefaults.standard.set(data, forKey: UserDefaultsKeys.userCalendars)
        }
    }
    var lastSeenOnboardingVersion: String {
        get { UserDefaults.standard.string(forKey: UserDefaultsKeys.lastSeenOnboardingVersion) ?? "" }
        set { UserDefaults.standard.setValue(newValue, forKey: UserDefaultsKeys.lastSeenOnboardingVersion) }
    }
    var user: User = User(email: "", imageUrl: "", name: "")
    var isLoggedIn: Bool = false
    var loginRestored: Bool = false
    var firstSyncProcessed: Bool = false
    var defaultCalendar: UserCalendar? {
        get {
            let jsonDecoder = JSONDecoder()
            guard let data = UserDefaults.standard.data(forKey: UserDefaultsKeys.defaultCalendar),
                  let defaultCalendar = try? jsonDecoder.decode(UserCalendar.self, from: data) else {
                return nil
            }
            return defaultCalendar
        }
        set {
            let jsonEncoder = JSONEncoder()
            guard let data = try? jsonEncoder.encode(newValue) else { return }
            UserDefaults.standard.set(data, forKey: UserDefaultsKeys.defaultCalendar)
        }
    }
}
