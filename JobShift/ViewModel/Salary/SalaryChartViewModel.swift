import Observation
import SwiftUI

@Observable class SalaryChartViewModel {
    let year: Int
    var chartData: [ChartEntry] = []
    var allSalary = 0
    var lastAllSalary = 0
    var totalColor: Color = .secondary
    var totalImageName = "arrow.forward"
    var jobs: [Job] = []
    var otJobs: [OneTimeJob] = []
    
    required init(year: Int, month: Int?) {
        self.year = year
    }
    
    func update(_ includeCommuteWage: Bool) {}
    
    func findSelectedSector(value: Int) -> ChartEntry? {
        var accumulatedCount = 0
        let entry = chartData.first { entry in
            accumulatedCount += entry.salary
            return value <= accumulatedCount
        }
        return entry
    }
}

struct ChartEntry: Identifiable, Hashable {
    let id = UUID()
    let label: String
    let salary: Int
    let minutes: Int
    let color: Color
    let isConfirm: Bool
    let confirmSalary: Int
    let count: Int
    let isOtJob: Bool
    let job: Job?
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    static func == (lhs: ChartEntry, rhs: ChartEntry) -> Bool {
        return lhs.id == rhs.id
    }
}

