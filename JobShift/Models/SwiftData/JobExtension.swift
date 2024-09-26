import Foundation

extension Job {
    // その月の給料日を返却
    func getPaymentDay(year: Int, month: Int) -> Date {
        let daysInMonth = Date(year: year, month: month, day: 1).daysInMonth
        var paymentDay = Date(year: year, month: month, day: min(self.salary.paymentDay, daysInMonth))
        while paymentDay.isHoliday {
            paymentDay = paymentDay.added(day: -1)
        }
        return paymentDay
    }
    
    // その月に支払われる給料の勤務期間を返却
    func getWorkInterval(year: Int, month: Int?) -> DateInterval {
        let startMonth = ((month ?? 1) - (self.salary.paymentType == .nextMonth ? 3 : 2) % 12) + 1
        let endMonth = month != nil ? startMonth + 1 : 12
        let startDaysCount = Date(year: year, month: startMonth, day: 1).daysInMonth
        let endDaysCount = Date(year: year, month: endMonth, day: 1).daysInMonth
        let startDate = Date(year: year, month: startMonth, day: min(self.salary.cutOffDay + 1, startDaysCount))
        let endDate = Date(year: year, month: endMonth, day: min(self.salary.cutOffDay, endDaysCount))
        return DateInterval(start: startDate.fixed(hour: 0, minute: 0, second: 0), end: endDate.fixed(hour: 23, minute: 59, second: 59))
    }

}
