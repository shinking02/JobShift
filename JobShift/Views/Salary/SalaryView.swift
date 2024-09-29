import SwiftUI
import SwiftData

enum DateMode: CaseIterable {
    case month
    case year
}

struct SalaryView: View {
    @Query private var jobs: [Job]
    @State private var dateMode: DateMode = .month
    @State private var includeCommuteWage = false
    @State private var showAddSalarySheet = false
    @State private var showDatePickerSheet = false
    @State private var selectedMonthDate: Date = .now
    @State private var selectedYearDate: Date = .now
    
    var navigationTitle: String {
            dateMode == .month
                ? "\(String(selectedMonthDate.year))年\(selectedMonthDate.month)月"
                : "\(String(selectedYearDate.year))年"
        }
    
    var body: some View {
        NavigationStack {
            VStack {
                if dateMode == .month {
                    PagedInfiniteScrollView(
                        changeIndex: $selectedMonthDate,
                        content: { date in
                            return SalaryContentView(date: date, dateMode: dateMode, addSheetIsPresented: $showAddSalarySheet, includeCommuteWage: $includeCommuteWage)
                        },
                        increaseIndexAction: { date in
                            return date.added(month: 1)
                        },
                        decreaseIndexAction: { date in
                            return date.added(month: -1)
                        },
                        shouldAnimateBetween: { date1, date2 in
                            if date1 == date2 { return (false, nil) }
                            return Calendar.current.isDate(date1, inSameDayAs: date2) ? (false, .forward) : date1.timeIntervalSince1970 < date2.timeIntervalSince1970 ? (true, .reverse) : (true, .forward)
                        },
                        transitionStyle: .scroll,
                        navigationOrientation: .horizontal
                    )
                    .transition(.move(edge: .leading))
                } else {
                    PagedInfiniteScrollView(
                        changeIndex: $selectedYearDate,
                        content: { date in
                            return SalaryContentView(date: date, dateMode: dateMode, addSheetIsPresented: $showAddSalarySheet, includeCommuteWage: $includeCommuteWage)
                        },
                        increaseIndexAction: { date in
                            return date.added(year: 1)
                        },
                        decreaseIndexAction: { date in
                            return date.added(year: -1)
                        },
                        shouldAnimateBetween: { date1, date2 in
                            if date1 == date2 { return (false, nil) }
                            return Calendar.current.isDate(date1, inSameDayAs: date2) ? (false, .forward) : date1.timeIntervalSince1970 < date2.timeIntervalSince1970 ? (true, .reverse) : (true, .forward)
                        },
                        transitionStyle: .scroll,
                        navigationOrientation: .horizontal
                    )
                    .transition(.move(edge: .trailing))
                }
            }
            .frame(maxWidth: .infinity)
            .background(Color(UIColor.systemGroupedBackground))
            .sheet(isPresented: $showDatePickerSheet) {
                DatePickerSheetView(dateMode: $dateMode, selectedDate: dateMode == .month ? $selectedMonthDate : $selectedYearDate)
                    .presentationDetents([.height(260)])
            }
            .sheet(isPresented: $showAddSalarySheet) {
                SelectableSalaryAddSheetView(date: dateMode == .month ? selectedMonthDate : selectedYearDate, selectedJob: jobs.first!)
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
                            withAnimation {
                                includeCommuteWage.toggle()
                            }
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

