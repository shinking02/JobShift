import SwiftUI
import Charts
import AudioToolbox
import SwiftData

struct SalaryView: View {
    @State var year: Int
    @State var month: Int?
    @State var unitType: UnitType
    @Binding var includeCommute: Bool
    // 中身を入れておかないと、onAppear時にgetSalariesが空だった場合Viewが更新されない
    @State private var salaries: [Salary] = [Salary(isConfirmed: false, confirmedWage: 0, forcastWage: 0, commuteWage: 0, events: [], count: 0, totalMinutes: 0)]
    @State private var lastSalaries: [Salary] = []
    @Query private var jobs: [Job]
    @Query private var otJobs: [OneTimeJob]
    @State private var selectedCount: Int?
    @State private var selectedSalary: Salary?
    
    let UIIFGeneratorLight = UIImpactFeedbackGenerator(style: .light)
    var body: some View {
        List {
            Section {
                ZStack {
                    Chart(salaries, id: \.self) { salary in
                        SectorMark(
                            angle: .value("", (salary.isConfirmed ? salary.confirmedWage : salary.forcastWage) + (includeCommute ? salary.commuteWage : 0)),
                            innerRadius: .ratio(0.8),
                            angularInset: 1.5
                        )
                        .cornerRadius(5)
                        .foregroundStyle(salary.job != nil ? salary.job!.color.getColor() : .secondary)
                        .foregroundStyle(by: .value("", salary.job?.name ?? "単発バイト"))
                        .opacity(selectedSalary == nil ? 1.0 : (selectedSalary == salary ? 1.0 : 0.5))
                    }
                    .chartLegend(.hidden)
                    .frame(height: 210)
                    .chartAngleSelection(value: $selectedCount)
                    .onChange(of: selectedCount) { oldValue, newValue in
                        if let newValue {
                            selectedSalary = findSelectedSector(value: newValue)
                        } else {
                            selectedSalary = nil
                        }
                    }
                    .onChange(of: selectedSalary) {
                        UIIFGeneratorLight.impactOccurred()
                    }
                    .chartBackground { chartProxy in
                        GeometryReader { geometry in
                            let frame = geometry[chartProxy.plotFrame!]
                            VStack {
                                if let selectedSalary = selectedSalary {
                                    Text(selectedSalary.job != nil
                                         ? selectedSalary.job!.name
                                         : "単発バイト")
                                    .font(.callout)
                                    .foregroundStyle(.secondary)
                                    let salary: Int = {
                                        if selectedSalary.job != nil {
                                            if selectedSalary.isConfirmed {
                                                return selectedSalary.confirmedWage + (includeCommute ? selectedSalary.commuteWage : 0)
                                            } else {
                                                return selectedSalary.forcastWage + (includeCommute ? selectedSalary.commuteWage : 0)
                                            }
                                        }
                                        return selectedSalary.confirmedWage + (includeCommute ? selectedSalary.commuteWage : 0)
                                    }()
                                    Text("\(salary)円")
                                        .font(.title2.bold())
                                } else {
                                    let totalSalary = salaries.reduce(0, { $0 + ($1.isConfirmed ? $1.confirmedWage : $1.forcastWage) })
                                    + (includeCommute ? salaries.reduce(0, { $0 + $1.commuteWage }) : 0)
                                    let lastTotalSalary = lastSalaries.reduce(0, { $0 + ($1.isConfirmed ? $1.confirmedWage : $1.forcastWage) })
                                    + (includeCommute ? lastSalaries.reduce(0, { $0 + $1.commuteWage }) : 0)
                                    let diff = totalSalary - lastTotalSalary
                                    let (color, image): (Color, String) = {
                                        if diff > 0 {
                                            return (.green, "arrow.up.forward")
                                        }
                                        if diff < 0 {
                                            return (.red, "arrow.down.forward")
                                        }
                                        return (.secondary, "arrow.forward")
                                    }()
                                    HStack {
                                        Text("\(abs(diff))円")
                                        Image(systemName: image)
                                    }
                                    .font(.caption)
                                    .foregroundStyle(color)
                                    Text("\(totalSalary)円")
                                        .font(.title2.bold())
                                }
                            }
                            .contentTransition(.numericText(countsDown: true))
                            .position(x: frame.midX, y: frame.midY)
                        }
                    }
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            HStack {
                                Image.init(systemName: "tram").font(.caption)
                                Text("交通費").font(.caption).lineLimit(1)
                            }.padding(4)
                                .foregroundColor(includeCommute ? Color(UIColor.secondarySystemGroupedBackground) : .blue)
                                .background(includeCommute ? Color.blue : Color(UIColor.secondarySystemGroupedBackground))
                                .cornerRadius(40)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 40)
                                        .stroke(Color.blue, lineWidth: 1.5)
                                    
                                ).onTapGesture {
                                    withAnimation {
                                        includeCommute.toggle()
                                        UIIFGeneratorLight.impactOccurred()
                                    }
                                }
                        }
                    }
                }
            }
            ForEach(salaries, id: \.self) { salary in
                    SalaryRow(salary: salary, includeCommute: $includeCommute)
            }
        }
        .onAppear {
            let lastYear = (month == nil || month == 1) ? year - 1 : year
            let lastMonth: Int? = {
                guard let month else { return nil }
                if month == 1 {
                    return 12
                }
                return month - 1
            }()
            self.salaries = SalaryManager.shared.getSalaries(jobs: jobs, otJobs: otJobs, year: year, month: month)
            self.lastSalaries = SalaryManager.shared.getSalaries(jobs: jobs, otJobs: otJobs, year: lastYear, month: lastMonth)
        }
    }
    private func findSelectedSector(value: Int) -> Salary? {
        var accumulatedCount = 0
        let salary = salaries.first { sa in
            accumulatedCount += sa.isConfirmed ? sa.confirmedWage : sa.forcastWage
            return value <= accumulatedCount
        }
        return salary
    }
}
