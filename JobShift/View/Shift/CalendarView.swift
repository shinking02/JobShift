//
// Created for UICalendarView_SwiftUI
// by Stewart Lynch on 2022-07-01
// Using Swift 5.0
//
// Follow me on Twitter: @StewartLynch
// Subscribe on YouTube: https://youTube.com/StewartLynch
//

import SwiftUI

struct CalendarView: UIViewRepresentable {
    @Bindable var viewModel: ShiftViewModel
    
    func makeUIView(context: Context) -> some UICalendarView {
        let view = UICalendarView()
        view.delegate = context.coordinator
        view.calendar = Calendar(identifier: .gregorian)
        let dateSelection = UICalendarSelectionSingleDate(delegate: context.coordinator)
        view.selectionBehavior = dateSelection
        view.locale = Locale(identifier: "ja_JP")
        view.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        view.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        view.backgroundColor = .clear
        dateSelection.setSelected(Calendar.current.dateComponents([.year, .month, .day], from: Date()), animated: true)
        return view
    }
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        if viewModel.shouldUpdateDecorationsOnAppear {
            uiView.reloadDecorations(forDateComponents: uiView.visibleDateComponents.monthDatesArray(), animated: true)
        }
        if !viewModel.decorationUpdatedDates.isEmpty {
            uiView.reloadDecorations(forDateComponents: viewModel.decorationUpdatedDates, animated: true)
        }
        viewModel.decorationReloaded()
    }
    
    class Coordinator: NSObject, UICalendarViewDelegate, UICalendarSelectionSingleDateDelegate {
        var parent: CalendarView
        init(parent: CalendarView) {
            self.parent = parent
        }
        
        @MainActor
        func calendarView(_ calendarView: UICalendarView, decorationFor dateComponents: DateComponents) -> UICalendarView.Decoration? {
            parent.viewModel.updateDecoration(dateComponents)
            guard let decoration = parent.viewModel.decorationStore[dateComponents] else {
                return nil
            }
            if let image = decoration.image {
                return .image(image, color: decoration.color, size: .large)
            }
            return .default(color: decoration.color)
        }
        
        func dateSelection(_ selection: UICalendarSelectionSingleDate, didSelectDate dateComponents: DateComponents?) {
            parent.viewModel.selectionBehavior(dateComponents)
        }
    }
}
