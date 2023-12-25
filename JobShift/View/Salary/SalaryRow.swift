import SwiftUI

struct SalaryRow: View {
    @State var salary: Salary
    @Binding var includeCommute: Bool
    var body: some View {
        Section {
            HStack {
                Rectangle()
                    .fill(salary.job?.color.getColor() ?? .secondary)
                    .frame(width: 3)
                    .cornerRadius(2)
                VStack {
                    NavigationLink(destination: EmptyView()) {
                        HStack {
                            Text(salary.job?.name ?? "単発バイト")
                                .bold()
                            Text(salary.isConfirmed ? "確定" : "見込み").font(.caption).lineLimit(1)
                                .foregroundColor(salary.isConfirmed ? .green : .orange)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .cornerRadius(40) 
                                .overlay(
                                    RoundedRectangle(cornerRadius: 40)
                                        .stroke(.secondary, lineWidth: 1.5))
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
}
