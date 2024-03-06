import SwiftUI

struct ShiftSheetView: View {
    @Environment(ShiftViewModel.self) var viewModel
    private let eventHelper = EventHelper()
    var body: some View {
        NavigationView {
            ScrollView {
                OnboardingView(
                    summary: "JobShiftの新機能",
                    detailURL: URL(string: "https://github.com/shinking02/JobShift/pull/42"),
                    features: [
                        Feature(title: "給料日の表示", description: "カレンダーに給料日が表示されるようになりました。", icon: "yensign"),
                        Feature(title: "パフォーマンスの向上", description: "すべての処理のパフォーマンスが向上し、より高速に低電力で安定して動作するようになりました。", icon: "bolt"),
                        Feature(title: "勤務開始日の設定", description: "定期バイトの勤務開始日を設定できるようになりました。", icon: "calendar"),
                        Feature(title: "UIの調整", description: "UIの細かな調整を全ページで行いました。これによりUXが格段に向上しています。", icon: "hand.tap")
                    ],
                    color: Color.blue
                )
                ForEach(viewModel.selectedDateEvents, id: \.id) { event in
                    Divider()
                        .padding(.horizontal)
                    HStack {
                        Rectangle()
                            .frame(width: 4)
                            .cornerRadius(2)
                            .foregroundStyle(eventHelper.getEventColor(event))
                        VStack(alignment: .leading) {
                            Text(event.summary)
                                .bold()
                                .lineLimit(1)
                        }
                        Spacer()
                    }
                    .padding(.horizontal)
                }
                ForEach(viewModel.selectedDateJobEvents, id: \.id) { event in
                    Divider()
                        .padding(.horizontal)
                    HStack {
                        Rectangle()
                            .frame(width: 4)
                            .cornerRadius(2)
                            .foregroundStyle(eventHelper.getEventColor(event))
                        VStack(alignment: .leading) {
                            Text(event.summary)
                                .bold()
                                .lineLimit(1)
                        }
                        Spacer()
                    }
                    .padding(.horizontal)
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Text(viewModel.selectedDate.toMdEString())
                        .font(.title3.bold())
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {}) {
                        Image(systemName: "plus")
                            .font(.title3)
                    }
                }
            }
        }
    }
}
