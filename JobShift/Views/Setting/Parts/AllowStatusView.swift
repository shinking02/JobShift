import PermissionsKit
import SwiftUI

struct AllowStatusStyle {
    var text: String
    var foregroundColor: Color
    var backgroundColor: Color
}

struct AllowStatusView: View {
    @Binding var status: Permission.Status
    
    var buttonStyle: AllowStatusStyle {
        switch status {
        case .authorized:
            return AllowStatusStyle(text: "ALLOWED", foregroundColor: Color(.white), backgroundColor: Color(.systemBlue))
        case .denied:
            return AllowStatusStyle(text: "DENIED", foregroundColor: Color(.white), backgroundColor: Color(.systemRed))
        default:
            return AllowStatusStyle(text: "ALLOW", foregroundColor: Color(.systemBlue), backgroundColor: Color(.systemGray5))
        }
    }
    var body: some View {
        Text(buttonStyle.text)
            .frame(width: 70)
            .font(.system(size: 15).bold())
            .lineLimit(1)
            .minimumScaleFactor(0.2)
            .foregroundColor(buttonStyle.foregroundColor)
            .padding(6)
            .background(
                Capsule()
                    .fill(buttonStyle.backgroundColor)
            )
    }
}
