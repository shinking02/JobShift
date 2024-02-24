import Foundation

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
}
