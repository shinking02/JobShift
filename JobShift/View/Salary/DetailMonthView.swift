import SwiftUI

struct DetailMonthView: View {
    @State var viewModel: DetailMonthViewModel
    
    var body: some View {
        List {
            Section {
                HStack {
                    Text("\(String(viewModel.yearMonth.year))年 \(String(viewModel.yearMonth.month))月")
                        .bold()
                    Spacer()
                    VStack {
                        HStack {
                            Spacer()
                            ConfirmChip(isConfirmed: true)
                            Text(viewModel.confirmSalary)
                                .font(.title2.bold())
                            + Text(" 円")
                                .foregroundColor(.secondary)
                        }
                        HStack {
                            Spacer()
                            ConfirmChip(isConfirmed: false)
                            Text(viewModel.forcastSalary)
                                .font(.title2.bold())
                            + Text(" 円")
                                .foregroundColor(.secondary)
                        }
                    }
                }
                NavigationLink(destination: EditSalaryHistoryView(viewModel: EditSalaryHistoryViewModel(job: viewModel.job))) {
                    Text("給与実績を編集")
                        .foregroundColor(.blue)
                }
            }
            Section {
                HStack {
                    VStack(alignment: .leading) {
                        let diff = viewModel.avgMinutes - viewModel.lastAvgMinutes
                        let (color, image): (Color, String) = {
                            if diff > 0 {
                                return (.green, "arrow.up")
                            }
                            if diff < 0 {
                                return (.red, "arrow.down")
                            }
                            return (.secondary, "arrow.forward")
                        }()
                        Text("平均勤務時間")
                            .font(.caption.bold())
                            .foregroundColor(.secondary)
                        HStack {
                            Text(String(viewModel.avgMinutes / 60))
                                .font(.title2.bold())
                            + Text(" 時間 ")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            + Text(String(viewModel.avgMinutes % 60))
                                .font(.title2.bold())
                            + Text(" 分")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            Group {
                                Text("\(String(abs(diff)))分")
                                    .foregroundColor(color)
                                    .font(.caption)
                                Image(systemName: image)
                                    .frame(width: 3)
                                    .foregroundColor(color)
                                    .font(.caption2)
                            }.offset(y: 3)
                        }
                    }
                    Spacer()
                    VStack(alignment: .leading) {
                        let diff = viewModel.count - viewModel.lastCount
                        let (color, image): (Color, String) = {
                            if diff > 0 {
                                return (.green, "arrow.up")
                            }
                            if diff < 0 {
                                return (.red, "arrow.down")
                            }
                            return (.secondary, "arrow.forward")
                        }()
                        Text("出勤回数")
                            .font(.caption.bold())
                            .foregroundColor(.secondary)
                        HStack {
                            Text(String(viewModel.count))
                                .font(.title2.bold())
                            + Text(" 回")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            Group {
                                Text("\(String(abs(diff)))回")
                                    .foregroundColor(color)
                                    .font(.caption)
                                Image(systemName: image)
                                    .frame(width: 3)
                                    .foregroundColor(color)
                                    .font(.caption2)
                            }.offset(y: 3)
                        }
                    }
                    Spacer()
                }
            }
            if !viewModel.details.isEmpty {
                Section(header: Text("勤務日")) {
                    ForEach(viewModel.details, id: \.self) { detail in
                        NavigationLink(destination: EditEventSummaryView(
                            viewModel: EditEventSummaryViewModel(job: viewModel.job, eventId: detail.event.id),
                            title: detail.dateText
                        )) {
                            HStack {
                                Text(detail.dateText)
                                if detail.hasAdjustment {
                                    Image(systemName: "yensign.circle")
                                        .foregroundColor(.secondary)
                                }
                                Text(detail.summary)
                                    .foregroundColor(.secondary)
                                    .font(.caption)
                                Spacer()
                                VStack {
                                    Text(detail.startText)
                                    if !detail.endText.isEmpty {
                                        Text(detail.endText)
                                    }
                                }
                                .foregroundColor(.secondary)
                                .font(.caption)
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle(viewModel.title)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.onAppear()
        }
    }
}
