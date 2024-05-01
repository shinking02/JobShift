import Foundation
import HolidayJp

extension TimeZone {
    
    static let japan = TimeZone(identifier: "Asia/Tokyo")!
}

extension Locale {
    
    static let japan = Locale(identifier: "ja_JP")
}

extension Date {
    
    var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = .japan
        calendar.locale   = .japan
        return calendar
    }
    
    var year: Int {
        return calendar.component(.year, from: self)
    }
    
    var month: Int {
        return calendar.component(.month, from: self)
    }
    
    var day: Int {
        return calendar.component(.day, from: self)
    }
    
    var hour: Int {
        return calendar.component(.hour, from: self)
    }
    
    var minute: Int {
        return calendar.component(.minute, from: self)
    }
    
    var second: Int {
        return calendar.component(.second, from: self)
    }
    
    var isHoliday: Bool {
        return HolidayJp.isHoliday(self) || self.weekIndex == 1 || self.weekIndex == 7
    }
    
    init(year: Int? = nil, month: Int? = nil, day: Int? = nil, hour: Int? = nil, minute: Int? = nil, second: Int? = nil) {
        self.init(
            timeIntervalSince1970: Date().fixed(
                year:   year,
                month:  month,
                day:    day,
                hour:   hour,
                minute: minute,
                second: second
            ).timeIntervalSince1970
        )
    }
    
    func fixed(year: Int? = nil, month: Int? = nil, day: Int? = nil, hour: Int? = nil, minute: Int? = nil, second: Int? = nil) -> Date {
        let calendar = self.calendar
        
        var comp = DateComponents()
        comp.year   = year   ?? calendar.component(.year,   from: self)
        comp.month  = month  ?? calendar.component(.month,  from: self)
        comp.day    = day    ?? calendar.component(.day,    from: self)
        comp.hour   = hour   ?? calendar.component(.hour,   from: self)
        comp.minute = minute ?? calendar.component(.minute, from: self)
        comp.second = second ?? calendar.component(.second, from: self)
        
        return calendar.date(from: comp)!
    }
    
    func added(year: Int? = nil, month: Int? = nil, day: Int? = nil, hour: Int? = nil, minute: Int? = nil, second: Int? = nil) -> Date {
        let calendar = self.calendar
        
        var comp = DateComponents()
        comp.year   = (year   ?? 0) + calendar.component(.year,   from: self)
        comp.month  = (month  ?? 0) + calendar.component(.month,  from: self)
        comp.day    = (day    ?? 0) + calendar.component(.day,    from: self)
        comp.hour   = (hour   ?? 0) + calendar.component(.hour,   from: self)
        comp.minute = (minute ?? 0) + calendar.component(.minute, from: self)
        comp.second = (second ?? 0) + calendar.component(.second, from: self)
        
        return calendar.date(from: comp)!
    }
    
    enum SymbolType {
        case `default`
        case standalone
        case veryShort
        case short
        case shortStandalone
        case veryShortStandalone
        case custom(symbols: [String])
    }
    
    var weekIndex: Int {
        return calendar.component(.weekday, from: self) - 1
    }
    
    func weeks(_ type: SymbolType = .short, locale: Locale? = nil) -> [String] {
        let formatter = DateFormatter()
        formatter.locale = locale ?? calendar.locale
        
        switch type {
        case .`default`:           return formatter.weekdaySymbols
        case .standalone:          return formatter.standaloneWeekdaySymbols
        case .veryShort:           return formatter.veryShortWeekdaySymbols
        case .short:               return formatter.shortWeekdaySymbols
        case .shortStandalone:     return formatter.shortStandaloneWeekdaySymbols
        case .veryShortStandalone: return formatter.veryShortStandaloneWeekdaySymbols
        case let .custom(symbols): return symbols
        }
    }
    
    func week(_ type: SymbolType = .short, locale: Locale? = nil) -> String {
        return weeks(type, locale: locale)[weekIndex]
    }
    
    var firstDayOfMonth: Date {
        return fixed(day: 1, hour: 0, minute: 0, second: 0)
    }
    
    var lastDayOfMonth: Date {
        return added(month: 1).fixed(day: 0, hour: 0, minute: 0, second: 0)
    }

    enum FormatType {
        case YYYYMD
        case MD
    }
    
    func toString(_ type: FormatType) -> String {
        let formatter = DateFormatter()
        formatter.locale = calendar.locale
        
        switch type {
        case .YYYYMD:
            formatter.dateStyle = .long
        case .MD:
            formatter.dateFormat = "M月d日"
        }
        return formatter.string(from: self)
    }
}
