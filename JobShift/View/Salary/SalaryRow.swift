import SwiftUI

struct SalaryRow: View {
    @State var salary: Salary
    @Binding var includeCommute: Bool
    @State var unitType: UnitType
    @State var year: Int
    @State var month: Int?
    
    var body: some View {
        Section {
            HStack {
                Rectangle()
                    .fill(salary.job?.color.getColor() ?? .secondary)
                    .frame(width: 3)
                    .cornerRadius(2)
                VStack {
                    NavigationLink(destination: DestinationView()) {
                        HStack {
                            Text(salary.job?.name ?? "単発バイト")
                                .bold()
                            ConfirmChip(isConfirmed: salary.isConfirmed)
                            Spacer()
                            Text("\(salary.count)出勤")
                                .foregroundColor(.secondary)
                                .font(.caption)
                        }
                    }
                    Spacer()
                    HStack {
                        Text("\((salary.isConfirmed ? salary.confirmedWage : salary.forcastWage) + (includeCommute ? salary.commuteWage : 0))")
                            .font(.title.bold())
                            + Text(" 円")
                                .foregroundColor(.secondary)
                        Spacer()
                        if salary.job != nil {
                            Text(String(salary.totalMinutes / 60))
                                .font(.title2.bold())
                            + Text(" 時間 ")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            + Text(String(salary.totalMinutes % 60))
                                .font(.title2.bold())
                            + Text(" 分")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .contentTransition(.numericText(countsDown: true))
                }
            }
            .frame(height: 80)
        }
        .listSectionSpacing(20)
    }
    @ViewBuilder
    private func DestinationView() -> some View {
        if let job = salary.job {
            if let month = month {
                DetailMonth(year: year, month: month, targetJob: job)
            } else {
                DetailYear(year: year, targetJob: job)
            }
        } else {
            if let month = month {
                OtDetailMonth(year: year, month: month)
            } else {
                OtDetailYear(year: year)
            }
        }
    }
}

struct ConfirmChip: View {
    @State var isConfirmed: Bool
    var body: some View {
        Text(isConfirmed ? "確定" : "見込み").font(.caption).lineLimit(1)
            .foregroundColor(isConfirmed ? .green : .orange)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .cornerRadius(40)
            .overlay(
                RoundedRectangle(cornerRadius: 40)
                    .stroke(.secondary, lineWidth: 1.5))
    }
}
