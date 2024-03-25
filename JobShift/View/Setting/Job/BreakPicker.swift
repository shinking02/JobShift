import Foundation
import SwiftUI

struct BreakPicker: View {
    @Binding var jobBreak: Break
    private let intervalMinutesArray = [120, 180, 240, 300, 360, 420, 480, 540]
    var body: some View {
        HStack {
            Picker("", selection: $jobBreak.breakIntervalMinutes) {
                ForEach(intervalMinutesArray, id: \.self) { minutes in
                    Text("\(minutes / 60) 時間").tag(minutes)
                }
            }.pickerStyle(.menu)
            Text("につき")
            Picker("", selection: $jobBreak.breakMinutes) {
                ForEach(1..<7, id: \.self) { i in
                    Text("\(i * 15) 分").tag(i * 15)
                }
            }.pickerStyle(.menu)
            Text("休憩")
        }
    }
}
