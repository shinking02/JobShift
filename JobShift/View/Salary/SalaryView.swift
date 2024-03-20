import Foundation
import SwiftUI
import SwiftData

struct SalaryView: View {
    @State private var currentPage: YearMonth = .origin
    @State private var currentYear: Int = Calendar.current.component(.year, from: Date())
    @State private var showMonth = true
    @State private var pickerIsPresented = false
    @State private var includeCommuteWage = false
    @State private var showSalaryAddSheet = false
    @Query private var jobs: [Job]

    var body: some View {
        NavigationStack {
            ZStack {
                if showMonth {
                    PagedInfiniteScrollView(content: { index in
                        SalaryChartView(
                            viewModel: SalaryMonthViewModel(year: index.year, month: index.month),
                            year: $currentPage.year,
                            month: $currentPage.month,
                            includeCommuteWage: $includeCommuteWage,
                            showSalaryAddSheet: $showSalaryAddSheet
                        )
                    }, currentPage: $currentPage)
                } else {
                    PagedInfiniteScrollView(content: { index in
                        SalaryChartView(
                            viewModel: SalaryYearViewModel(year: index, month: nil),
                            year: $currentYear,
                            month: .constant(0),
                            includeCommuteWage: $includeCommuteWage,
                            showSalaryAddSheet: $showSalaryAddSheet
                        )
                    }, currentPage: $currentYear)
                }
                if pickerIsPresented {
                    VStack {
                        CustomDatePicker(
                            selectedYear: showMonth ? $currentPage.year : $currentYear,
                            selectedMonth: $currentPage.month,
                            showMonth: showMonth
                        )
                            .background(.bar)
                            .frame(height: 210)
                            .cornerRadius(12)
                            .clipped()
                            .shadow(radius: 10)
                        Spacer()
                    }
                    .background(Color.black.opacity(0.0001))
                    .frame(maxWidth: .infinity)
                    .onTapGesture {
                        withAnimation(.spring(duration: 0.3)) {
                            self.pickerIsPresented = false
                        }
                    }
                    .zIndex(.infinity)
                    .transition(.scale(scale: 0, anchor: .top).combined(with: .opacity))
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: {
                        withAnimation(.spring(duration: 0.3)) {
                            pickerIsPresented = false
                            showMonth.toggle()
                        }
                    }) {
                        Image(systemName: showMonth ? "moon.fill" : "moon")
                    }
                }
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: {
                        withAnimation {
                            includeCommuteWage.toggle()
                        }
                    }) {
                        Image(systemName: includeCommuteWage ? "tram.fill" : "tram")
                    }
                }
                ToolbarItem(placement: .principal) {
                    Button(action: {
                        withAnimation(.spring(duration: 0.3)) {
                            pickerIsPresented.toggle()
                        }
                    }) {
                        Text("\(String(showMonth ? currentPage.year : currentYear))年\(showMonth ? "\(String(currentPage.month))月" : "")")
                            .bold()
                            .foregroundStyle(pickerIsPresented ? .blue : .primary)
                        Image(systemName: "chevron.down")
                            .frame(width: 20)
                            .rotationEffect(.degrees(pickerIsPresented ? 0 : -90))
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        showSalaryAddSheet = true
                    }) {
                        Image(systemName: "plus")
                    }
                    .disabled(jobs.isEmpty)
                }
            }
            .navigationBarTitle("", displayMode: .inline)
        }
    }
}
