import SwiftUI
import UIKit

// https://zenn.dev/kudachan/articles/189cef8059ed96

struct YearMonthPicker: UIViewRepresentable {
    @Binding var selectedYear: Int
    @Binding var selectedMonth: Int
    
    let years: [Int] = Array(1_900...2_100)
    let months: [Int] = Array(repeating: Array(1...12), count: 100).flatMap { $0 }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> UIPickerView {
        let pickerView = UIPickerView()
        pickerView.delegate = context.coordinator
        pickerView.dataSource = context.coordinator
        
        if let yearRow = years.firstIndex(of: selectedYear), let monthRow = months.firstIndex(of: selectedMonth) {
                
                pickerView.selectRow(yearRow, inComponent: 0, animated: false)
            
            // 初期位置を中央に設定することで、ループをシミュレート
                pickerView.selectRow(monthRow + 12 * 49, inComponent: 1, animated: false)
        }
        return pickerView
    }
    
    func updateUIView(_ uiView: UIPickerView, context: Context) {
        uiView.reloadAllComponents()
    }
    
    class Coordinator: NSObject, UIPickerViewDelegate, UIPickerViewDataSource {
        var parent: YearMonthPicker
        
        init(_ parent: YearMonthPicker) {
            self.parent = parent
        }
        
        func numberOfComponents(in pickerView: UIPickerView) -> Int {
            return 2
        }
        
        func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
            if component == 0 {
                return parent.years.count
            } else {
                return parent.months.count
            }
        }
        
        func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
            if component == 0 {
                return "\(parent.years[row])年"
            } else {
                return "\(parent.months[row])月"
            }
        }
        
        func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
            if component == 0 {
                parent.selectedYear = parent.years[row]
            } else {
                parent.selectedMonth = parent.months[row]
            }
        }
    }
}
