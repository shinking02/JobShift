import SwiftData
import SwiftUI

struct PaymentDayRowView: View {
    let job: Job
    let date: Date
    @State private var salary = 0
    var body: some View {
        HStack(alignment: .center) {
            Rectangle()
                .frame(width: 4, height: 32)
                .cornerRadius(2)
                .foregroundStyle(job.color.toColor())
            Text("\(job.name)給料日")
                .bold()
                .lineLimit(1)
            Spacer()
            Text("\(salary)円")
                .lineLimit(2)
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .onAppear {
            let salaryData = SalaryManager.shared.getSalaryData(date: date, jobs: [job], dateMode: .month).first!
            salary = salaryData.isConfirmed ? salaryData.confirmedSalary : salaryData.forecastSalary
        }
    }
}
