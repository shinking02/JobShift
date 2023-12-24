import SwiftUI

struct SalaryView: View {
    @State var salaries: [Salary]
    var body: some View {
        List {
            Text("\(salaries[0].forcastWage)")
        }
    }
}
