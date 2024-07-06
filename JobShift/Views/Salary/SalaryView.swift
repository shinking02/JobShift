import SwiftUI

enum NavigationTab: String, CaseIterable {
    case month = "月"
    case year = "年"
}

struct SalaryView: View {
    @State private var selectedTab: NavigationTab = .month
    @State private var selectedYearMonth = YearMonth.origin
    @State private var selectedYear = Year.origin
    @State private var includeCommuteWage = false
    @State private var showAddSalarySheet = false
    @State private var showDatePickerSheet = false
    
    var navigationTitle: String {
            selectedTab == .month
                ? "\(String(selectedYearMonth.year))年\(selectedYearMonth.month)月"
                : "\(String(selectedYear.year))年"
        }
    
    var body: some View {
        NavigationStack {
            Group {
                if selectedTab == .month {
                    PagedInfiniteScrollView(content: { index in
                        Text("\(String(index.year))年\(index.month)月")
                    }, currentPage: $selectedYearMonth)
                } else {
                    PagedInfiniteScrollView(content: { index in
                        Text("\(String(index.year))年")
                    }, currentPage: $selectedYear)
                }
            }
            .frame(maxWidth: .infinity)
            .background(Color(UIColor.systemGroupedBackground))
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle(navigationTitle)
            .toolbar {
                // iOS18の場合、NavigationBarが消える不具合がある https://forums.developer.apple.com/forums/thread/756734
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
            .sheet(isPresented: $showDatePickerSheet) {
                DatePickerSheetView(selectedTab: $selectedTab, selectedYearMonth: $selectedYearMonth, selectedYear: $selectedYear)
                    .presentationDetents([.height(260)])
            }
            .sheet(isPresented: $showAddSalarySheet) {
                Text("Add Salary Sheet")
            }
            .customHeaderView({
                NavigationTabs(selectedTab: $selectedTab)
            }, height: 32)
        }
    }
}

struct YearMonth: Steppable, Comparable {
    static var origin: YearMonth {
        let date = Date()
        return YearMonth(year: date.year, month: date.month)
    }

    static func < (lhs: YearMonth, rhs: YearMonth) -> Bool {
        if lhs.year == rhs.year {
            return lhs.month < rhs.month
        } else {
            return lhs.year < rhs.year
        }
    }

    var year: Int
    var month: Int

    func forward() -> YearMonth {
        let (newYear, newMonth) = month == 12
            ? (year + 1, 1)
            : (year, month + 1)
        return YearMonth(year: newYear, month: newMonth)
    }

    func backward() -> YearMonth {
        let (newYear, newMonth) = month == 1
            ? (year - 1, 12)
            : (year, month - 1)
        return YearMonth(year: newYear, month: newMonth)
    }
}

struct Year: Steppable, Comparable {
    static var origin: Year {
        let date = Date()
        return Year(year: date.year)
    }

    static func < (lhs: Year, rhs: Year) -> Bool {
        lhs.year < rhs.year
    }

    var year: Int

    func forward() -> Year {
        Year(year: year + 1)
    }

    func backward() -> Year {
        Year(year: year - 1)
    }
}
