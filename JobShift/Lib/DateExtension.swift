import Foundation
import HolidayJp

extension Date {
    func toMdString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "M月d日"
        return dateFormatter.string(from: self)
    }
    func toYYYYMdString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy年M月d日"
        if self == Date.distantFuture {
            return "現在"
        }
        return dateFormatter.string(from: self)
    }
    func toMdEString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ja_JP")
        dateFormatter.dateFormat = "M月d日 E曜日"
        return dateFormatter.string(from: self)
    }
    func isHoliday() -> Bool {
        let calendar = Calendar.current
        return HolidayJp.isHoliday(self) || calendar.component(.weekday, from: self) == 1 || calendar.component(.weekday, from: self) == 7
    }
}

extension DateComponents {
    func monthDatesArray(in calendar: Calendar = .current) -> [DateComponents] {
        guard self.date != nil else { return [] }
        let monthRange = calendar.range(of: .day, in: .month, for: self.date!)!
        return monthRange.map { day in
              var components = self
              components.day = day
              return components
        }
    }
}
