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
    let selectionBehavior: (DateComponents?) -> Void
    let decorationFor: (DateComponents) -> UICalendarView.Decoration?
    
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
        uiView.reloadDecorations(forDateComponents: uiView.visibleDateComponents.monthDatesArray(), animated: true)
    }
    
    class Coordinator: NSObject, UICalendarViewDelegate, UICalendarSelectionSingleDateDelegate {
        var parent: CalendarView
        init(parent: CalendarView) {
            self.parent = parent
        }
        
        @MainActor
        func calendarView(_ calendarView: UICalendarView, decorationFor dateComponents: DateComponents) -> UICalendarView.Decoration? {
           let decoration = parent.decorationFor(dateComponents)
           return decoration
        }
        
        func dateSelection(_ selection: UICalendarSelectionSingleDate, didSelectDate dateComponents: DateComponents?) {
            parent.selectionBehavior(dateComponents)
        }
        
        
    }
}
