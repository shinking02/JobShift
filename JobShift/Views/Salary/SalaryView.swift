import SwiftUI

enum DateMode: CaseIterable {
    case month
    case year
}

struct SalaryView: View {
    @State private var dateMode: DateMode = .month
    @State private var includeCommuteWage = false
    @State private var showAddSalarySheet = false
    @State private var showDatePickerSheet = false
    @State private var selectedDate: Date = .now
    
    var navigationTitle: String {
            dateMode == .month
                ? "\(String(selectedDate.year))年\(selectedDate.month)月"
                : "\(String(selectedDate.year))年"
        }
    
    var body: some View {
        NavigationStack {
            VStack {
                PagedInfiniteScrollView(
                    changeIndex: $selectedDate,
                    content: { month in
                        Text("\(month)")
                    },
                    increaseIndexAction: { currentDate in
                        return currentDate.added(month: 1)
                    },
                    decreaseIndexAction: { currentDate in
                        return currentDate.added(month: -1)
                    },
                    shouldAnimateBetween: { date1, date2 in
                        if date1 == date2 { return (false, .forward) }
                        return Calendar.current.isDate(date1, inSameDayAs: date2) ? (false, .forward) : date1.timeIntervalSince1970 < date2.timeIntervalSince1970 ? (true, .reverse) : (true, .forward)
                    },
                    transitionStyle: .scroll,
                    navigationOrientation: .horizontal
                )
            }
            .frame(maxWidth: .infinity)
            .background(Color(UIColor.systemGroupedBackground))
            .sheet(isPresented: $showDatePickerSheet) {
                DatePickerSheetView(dateMode: $dateMode, selectedDate: $selectedDate)
                    .presentationDetents([.height(260)])
            }
            .sheet(isPresented: $showAddSalarySheet) {
                Text("Add Salary Sheet")
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle(navigationTitle)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(
                        action: {
                        showDatePickerSheet = true
                        },
                        label: {
                            Image(systemName: "calendar")
                        }
                    )
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(
                        action: {
                        includeCommuteWage.toggle()
                        },
                        label: {
                            Image(systemName: includeCommuteWage ? "tram.circle.fill" : "tram.circle")
                        }
                    )
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(
                        action: {
                        showAddSalarySheet = true
                        },
                        label: {
                            Image(systemName: "plus")
                        }
                    )
                }
            }
            .customHeaderView({
                NavigationTabs(dateMode: $dateMode)
            }, height: 32)
        }
    }
}

