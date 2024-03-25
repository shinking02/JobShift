import SwiftUI
import UIKit

struct CustomDatePicker: UIViewRepresentable {
    @Binding var selectedYear: Int
    @Binding var selectedMonth: Int
    var showMonth: Bool
    
    let years: [Int] = Array(1_900...2_100)
    let months: [Int] = Array(repeating: Array(1...12), count: 100).flatMap { $0 }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self, showMonth: showMonth)
    }
    
    func makeUIView(context: Context) -> UIPickerView {
        let pickerView = UIPickerView()
        pickerView.delegate = context.coordinator
        pickerView.dataSource = context.coordinator
        
        if let yearRow = years.firstIndex(of: selectedYear), let monthRow = months.firstIndex(of: selectedMonth) {
            pickerView.selectRow(yearRow, inComponent: 0, animated: false)
            
            if showMonth {
                // 初期位置を中央に設定することで、ループをシミュレート
                pickerView.selectRow(monthRow + 12 * 49, inComponent: 1, animated: false)
            }
        }
        return pickerView
    }
    
    func updateUIView(_ uiView: UIPickerView, context: Context) {
        uiView.reloadAllComponents()
    }
    
    class Coordinator: NSObject, UIPickerViewDelegate, UIPickerViewDataSource {
        var parent: CustomDatePicker
        var showMonth: Bool
        
        init(parent: CustomDatePicker, showMonth: Bool) {
            self.parent = parent
            self.showMonth = showMonth
        }
        
        func numberOfComponents(in pickerView: UIPickerView) -> Int {
            return showMonth ? 2 : 1
        }
        
        func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
            if showMonth {
                if component == 0 {
                    return parent.years.count
                } else {
                    return parent.months.count
                }
            } else {
                return parent.years.count
            }
        }
        
        func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
            if showMonth {
                if component == 0 {
                    return "\(parent.years[row])年"
                } else {
                    return "\(parent.months[row])月"
                }
            } else {
                return "\(parent.years[row])年"
            }
        }
        
        func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
            if showMonth {
                if component == 0 {
                    parent.selectedYear = parent.years[row]
                } else {
                    parent.selectedMonth = parent.months[row]
                }
            } else {
                parent.selectedYear = parent.years[row]
            }
        }
    }
}
