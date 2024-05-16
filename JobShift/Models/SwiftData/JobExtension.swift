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
    func getWorkInterval(year: Int, month: Int) -> DateInterval {
        return DateInterval()
    }
}
