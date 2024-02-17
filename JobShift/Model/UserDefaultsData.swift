import Foundation

enum UserDefaultsKeys {
    static let lastSyncedEmail = "LAST_SYNCED_EMAIL"
    static let activeCallIds = "ACTIVE_CALL_IDS"
    static let showOnlyJobEventSetting = "SHOW_ONLY_JOBEVENT_SETTING"
    static let googleSyncToken = "GOOGLE_SYNC_TOKEN"
    static let isDevelopperMode = "IS_DEVELOPPER_MODE"
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
    
    func getActiveCalIds() -> [String] {
        return userDefaults.stringArray(forKey: UserDefaultsKeys.activeCallIds) ?? []
    }

    func setActiveCallIds(_ ids: [String]) {
        userDefaults.set(ids, forKey: UserDefaultsKeys.activeCallIds)
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

    func clearAll() {
        setActiveCallIds([])
        setShowOnlyJobEventSetting(false)
        setIsDevelopperMode(false)
    }
}
