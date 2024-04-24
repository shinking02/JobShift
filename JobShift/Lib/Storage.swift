import Foundation

enum UserDefaultsKeys {
//    static let lastSyncedEmail = "LAST_SYNCED_EMAIL"
//    static let isShowOnlyJobEvent = "IS_SHOW_ONLY_JOBEVENT"
//    static let googleSyncToken = "GOOGLE_SYNC_TOKEN"
//    static let isDevelopperMode = "IS_DEVELOPPER_MODE"
//    static let userCalendars = "USER_CALENDARS"
//    static let lastSeenOnboardingVersion = "LAST_SEEN_ONBOARDING_VERSION"
//    static let defaultCalendar = "DEFAULT_CALENDAR"
    static let disableCalendarIds = "DISABLE_CALENDAR_IDS"
}

struct Storage {
    static func getDisableCalendarIds() -> [String] {
        return UserDefaults.standard.stringArray(forKey: UserDefaultsKeys.disableCalendarIds) ?? []
    }
    static func setDisableCalendarIds(ids: [String]) {
        UserDefaults.standard.set(ids, forKey: UserDefaultsKeys.disableCalendarIds)
    }
}
