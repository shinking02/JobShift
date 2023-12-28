import Foundation
import SwiftUI
import SwiftData

struct SalaryMainView: View {
    @EnvironmentObject private var eventStore: EventStore
    @Query private var jobs: [Job]
    @Query private var otJobs: [OneTimeJob]
    @State private var selectedUnit: UnitType = UnitType.month
    @State private var pickerIsPresented = false
    @State private var yearSelection: Int = {
        let currentDate = Date()
        let calendar = Calendar.current
        return calendar.component(.year, from: currentDate)
    }()
    @State private var monthSelection: Int = {
        let currentDate = Date()
        let calendar = Calendar.current
        return calendar.component(.month, from: currentDate)
    }()
    @State private var pages: [SalaryPage] = {
        let currentDate = Date()
        let calendar = Calendar.current
        let currentMonth = calendar.component(.month, from: currentDate)
        let currentYear = calendar.component(.year, from: currentDate)
        
        let lastMonthObject = SalaryPage(year: currentMonth > 1 ? currentYear : currentYear - 1, month: currentMonth > 1 ? currentMonth - 1 : 12)
        let currentMonthObject = SalaryPage(year: currentYear, month: currentMonth)
        let nextMonthObject = SalaryPage(year: currentMonth < 12 ? currentYear : currentYear + 1, month: currentMonth < 12 ? currentMonth + 1 : 1)
        
        return [lastMonthObject, currentMonthObject, nextMonthObject]
    }()
    @State private var includeCommute = false
    @State private var showAddSalaryView = false
    private let salaryManager: SalaryManager = SalaryManager.shared

    var body: some View {
        NavigationView {
            ZStack {
                InfinitePagingView(objects: $pages, pagingHandler: handlePageChange) { yearMonth in
                    SalaryView(year: yearMonth.year, month: yearMonth.month, unitType: selectedUnit, includeCommute: $includeCommute)
                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Menu(content: {
                            Picker(selection: $selectedUnit, label: Image(systemName: "calendar")) {
                                ForEach([UnitType.month, UnitType.year], id: \.self) { unit in
                                    Text("\(unit == UnitType.month ? "月" : "年")")
                                }
                            }
                            .onChange(of: selectedUnit) {
                                updatePages()
                            }
                        }, label: {
                            Image(systemName: "calendar")
                        })
                    }
                    ToolbarItem(placement: .principal) {
                        Button(action: {
                            withAnimation {
                                pickerIsPresented.toggle()
                            }
                        }) {
                            Text("\(String(yearSelection))年\(selectedUnit == UnitType.month ? "\(String(monthSelection))月" : "")")
                                .bold()
                                .tint(Color(UIColor.label))
                            Image(systemName: "chevron.down")
                                .frame(width: 20)
                                .rotationEffect(.degrees(pickerIsPresented ? 0 : -90))
                        }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            self.showAddSalaryView = true
                        }) {
                            Image(systemName: "plus")
                        }
                        .disabled(jobs.count == 0)
                    }
                }
                if pickerIsPresented {
                    VStack {
                        CustomDatePicker(selectedYear: $yearSelection, selectedMonth: $monthSelection, showMonth: selectedUnit == UnitType.month)
                            .background(.ultraThinMaterial)
                            .frame(height: 210)
                            .cornerRadius(12)
                            .shadow(radius: 5)
                        Spacer()
                    }
                    .background(Color.black.opacity(0.0001))
                    .onTapGesture {
                        withAnimation {
                            self.pickerIsPresented = false
                        }
                    }
                    .zIndex(.infinity)
                    .transition(.scale(scale: 0, anchor: .top).combined(with: .opacity))
                }
            }
            .navigationBarTitle("", displayMode: .inline)
            .onChange(of: pickerIsPresented) {
                if !pickerIsPresented {
                    updatePages()
                }
            }
            .sheet(isPresented: $showAddSalaryView, onDismiss: {
                pages[1] = SalaryPage(year: yearSelection, month: selectedUnit == UnitType.month ? monthSelection : nil)
            }){
                SalaryAddView(year: yearSelection, month: monthSelection, selectedJob: jobs[0])
            }
        }
    }
    private func handlePageChange(direction: PageDirection) {
        withAnimation {
            self.pickerIsPresented = false
        }
        switch direction {
        case .backward:
            pages[2] = pages[1]
            pages[1] = pages[0]
            
            if self.selectedUnit == UnitType.month {
                if self.monthSelection > 1 {
                    self.monthSelection -= 1
                } else {
                    self.yearSelection -= 1
                    self.monthSelection = 12
                }
                let (year, month): (Int, Int) = {
                    if monthSelection > 1 {
                        return (yearSelection, monthSelection - 1)
                    } else {
                        return (yearSelection - 1, 12)
                    }
                }()
                pages[0] = SalaryPage(year: year, month: month)
            } else {
                self.yearSelection -= 1
                pages[0] = SalaryPage(year: yearSelection - 1)
            }
        case .forward:
            pages[0] = pages[1]
            pages[1] = pages[2]
            if self.selectedUnit == UnitType.month {
                if self.monthSelection < 12 {
                    self.monthSelection += 1
                } else {
                    self.yearSelection += 1
                    self.monthSelection = 1
                }
                let (year, month): (Int, Int) = {
                    if monthSelection < 12 {
                        return (yearSelection, monthSelection + 1)
                    } else {
                        return (yearSelection + 1, 1)
                    }
                }()
                pages[2] = SalaryPage(year: year, month: month)
            } else {
                self.yearSelection += 1
                pages[2] = SalaryPage(year: yearSelection + 1)
            }
        }
    }
    private func updatePages() {
        if self.selectedUnit == UnitType.month {
            var previousYear = yearSelection
            var previousMonth = monthSelection - 1
            if previousMonth == 0 {
                previousMonth = 12
                previousYear -= 1
            }
            var nextYear = yearSelection
            var nextMonth = monthSelection + 1
            if nextMonth == 13 {
                nextMonth = 1
                nextYear += 1
            }
            pages[0] = SalaryPage(year: previousYear, month: previousMonth)
            pages[1] = SalaryPage(year: yearSelection, month: monthSelection)
            pages[2] = SalaryPage(year: nextYear, month: nextMonth)
        } else {
            pages[0] = SalaryPage(year: yearSelection - 1)
            pages[1] = SalaryPage(year: yearSelection)
            pages[2] = SalaryPage(year: yearSelection + 1)
        }
    }
}

enum UnitType: String {
    case month
    case year
}

struct SalaryPage: Hashable, Identifiable {
    let id = UUID()
    var year: Int
    var month: Int?
}
