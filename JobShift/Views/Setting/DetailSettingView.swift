import SwiftUI

struct DetailSettingView: View {
    @State private var isEnableEventSuggest = !Storage.getIsDisableEventSuggest()
    @State private var suggestEventIntervalWeek = Storage.getEventSuggestIntervalWeek() == 0 ? 3 : Storage.getEventSuggestIntervalWeek()
    var body: some View {
        NavigationStack {
            List {
                Toggle("シフトの提案", isOn: $isEnableEventSuggest)
                    .onChange(of: isEnableEventSuggest) {
                        Storage.setIsDisableEventSuggest(!isEnableEventSuggest)
                    }
                Picker("提案に使用する期間", selection: $suggestEventIntervalWeek) {
                    ForEach(1...5, id: \.self) { week in
                        Text("\(week)週間")
                    }
                }
                .onChange(of: suggestEventIntervalWeek) {
                    Storage.setEventSuggestIntervalWeek(suggestEventIntervalWeek)
                }
            }
            .navigationTitle("詳細")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
