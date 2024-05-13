import Foundation

extension Job {
    func getPaymentDay(year: Int, month: Int) -> Date {
        let daysInMonth = Date(year: year, month: month, day: 1).daysInMonth
        var paymentDay = Date(year: year, month: month, day: min(self.salary.paymentDay, daysInMonth))
        while paymentDay.isHoliday {
            paymentDay = paymentDay.added(day: -1)
        }
        return paymentDay
    }
    
    func getWorkInterval(year: Int, month: Int) -> DateInterval {
        return DateInterval()
    }
}
