import SwiftUI

struct NumberTextField: View {
    @Binding var number: Int
    @State private var text = ""
    let label: String
    
    init(number: Binding<Int>, label: String = "") {
         self._number = number
        self._text = State(initialValue: "\(number.wrappedValue)")
        self.label = label
    }
    
    var body: some View {
        TextField(label, text: $text)
            .keyboardType(.numberPad)
            .onChange(of: text) {
                if let value = Int(text) {
                    number = value
                }
            }
    }
}
