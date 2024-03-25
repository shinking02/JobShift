import SwiftUI

struct ShiftSheetView: View {
    @Environment(ShiftViewModel.self) var viewModel
    @State private var editingEvent: ShiftViewEvent?
    @State private var addingEvent: ShiftViewEvent?
    
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
                        Feature(title: "入社日の設定", description: "定期バイトの入社日を設定できるようになりました。", icon: "calendar"),
                        Feature(title: "UIの調整", description: "UIの細かな調整を全ページで行いました。これによりUXが向上しています。", icon: "hand.tap")
                    ],
                    color: Color.blue
                )
                if viewModel.selectedDateEvents.isEmpty {
                    Text("予定がありません")
                        .font(.title3)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding()
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(viewModel.selectedDateEvents, id: \.id) { event in
                        Divider()
                            .padding(.horizontal)
                        HStack {
                            Rectangle()
                                .frame(width: 4, height: 32)
                                .cornerRadius(2)
                                .foregroundStyle(event.color)
                            VStack(alignment: .leading) {
                                Text(event.title)
                                    .bold()
                                    .lineLimit(1)
                            }
                            Spacer()
                            VStack(alignment: .trailing) {
                                Text(event.detailText1)
                                if let detailText2 = event.detailText2 {
                                    Text(detailText2)
                                }
                            }
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        }
                        .padding(.horizontal)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            if event.canEdit {
                                editingEvent = event
                            }
                        }
                    }
                }
                if !viewModel.selectedDateSuggests.isEmpty {
                    Text("提案")
                        .font(.caption)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top)
                        .padding(.horizontal)
                        .foregroundStyle(.secondary)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(viewModel.selectedDateSuggests, id: \.id) { suggest in
                                SuggestCardView(suggest: suggest)
                                    .onTapGesture {
                                        addingEvent = suggest
                                    }
                            }
                        }
                    }
                    .safeAreaPadding(.horizontal)
                }
            }
            .sheet(item: $editingEvent, onDismiss: viewModel.onAppear) { event in
                EventEditView(event: event)
            }
            .sheet(item: $addingEvent, onDismiss: viewModel.onAppear) { event in
                EventAddView(event: event)
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Text("\(viewModel.selectedDate.toMdEString(brackets: false))曜日")
                        .font(.title3.bold())
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        addingEvent = ShiftViewEvent(
                            id: UUID().uuidString,
                            color: .secondary,
                            title: "",
                            summary: nil,
                            detailText1: "",
                            detailText2: nil,
                            canEdit: false,
                            calendarId: "",
                            isAllday: true,
                            start: viewModel.selectedDate,
                            end: viewModel.selectedDate
                        )

                    }, label: {
                        Image(systemName: "plus")
                            .font(.title3)
                    })
                    .disabled(!viewModel.canAddEvent)
                }
            }
        }
    }
}
