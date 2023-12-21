import Foundation
import SwiftUI

struct SalaryView: View {
    @State private var objects = [0, 1, 2]
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
    
    var body: some View {
        NavigationView {
            ZStack {
                InfinitePagingView(objects: $objects, pagingHandler: handlePageChange) { object in
                    List {
                        Text("\(object)")
                    }
                    .onTapGesture {
                        withAnimation {
                            self.pickerIsPresented = false
                        }
                    }
                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Menu(content: {
                            Picker(selection: $selectedUnit, label: Image(systemName: "calendar")) {
                                ForEach([UnitType.month, UnitType.year], id: \.self) { unit in
                                    Text("\(unit == UnitType.month ? "月" : "年")")
                                }
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
                            Text("\(String(yearSelection))年\( selectedUnit == UnitType.month ? "\(String(monthSelection))月" : "")")
                                .bold()
                                .tint(Color(UIColor.label))
                            Image(systemName: "chevron.down")
                                .frame(width: 20)
                                .rotationEffect(.degrees(pickerIsPresented ? 0 : -90))
                        }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            
                        }) {
                            Image(systemName: "plus")
                        }
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
                    .zIndex(.infinity)
                    .transition(.scale(scale: 0, anchor: .top).combined(with: .opacity))
                }
            }
            .navigationBarTitle("", displayMode: .inline)
        }
    }
    func handlePageChange(direction: PageDirection) {
        withAnimation {
            self.pickerIsPresented = false
        }
        switch direction {
        case .backward:
            if self.selectedUnit == UnitType.month {
                if self.monthSelection > 1 {
                    self.monthSelection -= 1
                } else {
                    self.yearSelection -= 1
                    self.monthSelection = 12
                }
            } else {
                self.yearSelection -= 1
            }
        case .forward:
            if self.selectedUnit == UnitType.month {
                if self.monthSelection < 12 {
                    self.monthSelection += 1
                } else {
                    self.yearSelection += 1
                    self.monthSelection = 1
                }
            } else {
                self.yearSelection += 1
            }
        }
    }
}

enum UnitType: String {
    case month
    case year
}
