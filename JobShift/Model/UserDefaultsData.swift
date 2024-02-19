import Foundation

enum UserDefaultsKeys {
    static let lastSyncedEmail = "LAST_SYNCED_EMAIL"
    static let showOnlyJobEventSetting = "SHOW_ONLY_JOBEVENT_SETTING"
    static let googleSyncToken = "GOOGLE_SYNC_TOKEN"
    static let isDevelopperMode = "IS_DEVELOPPER_MODE"
    static let activeCalendars = "ACTIVE_CALENDARS"
    static let allCalendars = "ALL_CALENDARS"
}

struct UserCalendar: Codable, Hashable {
    var id: String
    var name: String
}

final class UserDefaultsData {
    static let shared: UserDefaultsData = .init()
    private init() {}
    private let userDefaults = UserDefaults.standard

    func getLastSyncedEmail() -> String {
        return userDefaults.string(forKey: UserDefaultsKeys.lastSyncedEmail) ?? ""
    }
    
    func setLastSyncedEmail(_ email: String) {
        userDefaults.setValue(email, forKey: UserDefaultsKeys.lastSyncedEmail)
    }

    func getShowOnlyJobEventSetting() -> Bool {
        return userDefaults.bool(forKey: UserDefaultsKeys.showOnlyJobEventSetting)
    }

    func setShowOnlyJobEventSetting(_ value: Bool) {
        userDefaults.set(value, forKey: UserDefaultsKeys.showOnlyJobEventSetting)
    }

    func getGoogleSyncTokens() -> [String: String] {
        return userDefaults.dictionary(forKey: UserDefaultsKeys.googleSyncToken) as? [String: String] ?? [:]
    }

    func setGoogleSyncTokens(_ tokens: [String: String]) {
        userDefaults.set(tokens, forKey: UserDefaultsKeys.googleSyncToken)
    }
    
    func getIsDevelopperMode() -> Bool {
        return userDefaults.bool(forKey: UserDefaultsKeys.isDevelopperMode)
    }
    
    func setIsDevelopperMode(_ value: Bool) {
        userDefaults.set(value, forKey: UserDefaultsKeys.isDevelopperMode)
    }
    
    func getActiveCalendars() -> [UserCalendar] {
        let jsonDecoder = JSONDecoder()
        guard let data = userDefaults.data(forKey: UserDefaultsKeys.activeCalendars),
              let activeCalendars = try? jsonDecoder.decode([UserCalendar].self, from: data) else {
            return []
        }
        return activeCalendars
    }
    
    func setActiveCalendars(_ activeCalendars: [UserCalendar]) {
        let jsonEncoder = JSONEncoder()
        guard let data = try? jsonEncoder.encode(activeCalendars) else {
            return
        }
        userDefaults.set(data, forKey: UserDefaultsKeys.activeCalendars)
    }
    
    func getAllCalendars() -> [UserCalendar] {
        let jsonDecoder = JSONDecoder()
        guard let data = userDefaults.data(forKey: UserDefaultsKeys.allCalendars),
              let allCalendars = try? jsonDecoder.decode([UserCalendar].self, from: data) else {
            return []
        }
        return allCalendars
    }
    
    func setAllCalendars(_ allCalendars: [UserCalendar]) {
        let jsonEncoder = JSONEncoder()
        guard let data = try? jsonEncoder.encode(allCalendars) else {
            return
        }
        userDefaults.set(data, forKey: UserDefaultsKeys.allCalendars)
    }

    func clearAll() {
        setActiveCalendars([])
        setAllCalendars([])
        setShowOnlyJobEventSetting(false)
        setIsDevelopperMode(false)
    }
}
