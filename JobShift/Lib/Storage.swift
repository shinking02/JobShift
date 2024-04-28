import Foundation

enum UserDefaultsKeys {
//    static let lastSyncedEmail = "LAST_SYNCED_EMAIL"
//    static let googleSyncToken = "GOOGLE_SYNC_TOKEN"
//    static let isDevelopperMode = "IS_DEVELOPPER_MODE"
//    static let userCalendars = "USER_CALENDARS"
    static let lastSeenOnboardingVersion = "JS_LAST_SEEN_ONBOARDING_VERSION"
    static let defaultCalendarId = "JS_DEFAULT_CALENDAR_ID"
    static let disableCalendarIds = "JS_DISABLE_CALENDAR_IDS"
    static let isShowOnlyJobEvent = "JS_IS_SHOW_ONLY_JOBEVENT"
    static let enableSalaryPaymentNotification = "JS_ENABLE_SALARY_PAYMENT_NOTIFICATION"
}

struct Storage {
    static func getDisableCalendarIds() -> [String] {
        return UserDefaults.standard.stringArray(forKey: UserDefaultsKeys.disableCalendarIds) ?? []
    }
    static func setDisableCalendarIds(_ ids: [String]) {
        UserDefaults.standard.set(ids, forKey: UserDefaultsKeys.disableCalendarIds)
    }
    static func getIsShowOnlyJobEvent() -> Bool {
        return UserDefaults.standard.bool(forKey: UserDefaultsKeys.isShowOnlyJobEvent)
    }
    static func setIsShowOnlyJobEvent(_ isShowOnlyJobEvent: Bool) {
        UserDefaults.standard.set(isShowOnlyJobEvent, forKey: UserDefaultsKeys.isShowOnlyJobEvent)
    }
    static func getDefaultCalendarId() -> String {
        return UserDefaults.standard.string(forKey: UserDefaultsKeys.defaultCalendarId) ?? ""
    }
    static func setDefaultCalendarId(_ id: String) {
        UserDefaults.standard.set(id, forKey: UserDefaultsKeys.defaultCalendarId)
    }
    static func getEnableSalaryPaymentNotification() -> Bool {
        return UserDefaults.standard.bool(forKey: UserDefaultsKeys.enableSalaryPaymentNotification)
    }
    static func setEnableSalaryPaymentNotification(_ value: Bool) {
        UserDefaults.standard.set(value, forKey: UserDefaultsKeys.enableSalaryPaymentNotification)
    }
    static func getLastSeenOnboardingVersion() -> String {
        return UserDefaults.standard.string(forKey: UserDefaultsKeys.lastSeenOnboardingVersion) ?? ""
    }
    static func setLastSeenOnboardingVersion(_ version: String) {
        UserDefaults.standard.set(version, forKey: UserDefaultsKeys.lastSeenOnboardingVersion)
    }
}
