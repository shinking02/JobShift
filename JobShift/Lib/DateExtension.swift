import Foundation

extension Date {
    func toMdString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "M月d日"
        return dateFormatter.string(from: self)
    }
}
