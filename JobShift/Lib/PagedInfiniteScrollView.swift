//
//  PagedInfiniteScrollView.swift
//  InfinitePageView
//
//  Created by beader on 2023/4/19.
//

import SwiftUI
import UIKit
import Foundation

protocol Steppable {
    static var origin: Self { get }

    func forward() -> Self
    func backward() -> Self
}

extension Int: Steppable {
    static var origin: Int {
        return 0
    }
    
    func forward() -> Int {
        return self + 1
    }

    func backward() -> Int {
        return self - 1
    }
}

struct YearMonth: Steppable, Comparable {
    var year: Int
    var month: Int

    func forward() -> YearMonth {
        if month == 12 {
            return YearMonth(year: year + 1, month: 1)
        } else {
            return YearMonth(year: year, month: month + 1)
        }
    }

    func backward() -> YearMonth {
        if month == 1 {
            return YearMonth(year: year - 1, month: 12)
        } else {
            return YearMonth(year: year, month: month - 1)
        }
    }
    
    static func < (lhs: YearMonth, rhs: YearMonth) -> Bool {
        if lhs.year == rhs.year {
            return lhs.month < rhs.month
        } else {
            return lhs.year < rhs.year
        }
    }
    
    static var origin: YearMonth {
        let components = Calendar.current.dateComponents([.year, .month], from: .now)
        return YearMonth(year: components.year ?? 0, month: components.month ?? 0)
    }
}

struct PagedInfiniteScrollView<S: Steppable & Comparable, Content: View>: UIViewControllerRepresentable {
    typealias UIViewControllerType = UIPageViewController

    let content: (S) -> Content
    @Binding var currentPage: S

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: Context) -> UIPageViewController {
        let pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal)
        pageViewController.dataSource = context.coordinator
        pageViewController.delegate = context.coordinator

        let initialViewController = UIHostingController(rootView: IdentifiableContent(index: currentPage, content: { content(currentPage) }))
        pageViewController.setViewControllers([initialViewController], direction: .forward, animated: false, completion: nil)

        return pageViewController
    }

    func updateUIViewController(_ uiViewController: UIPageViewController, context: Context) {
        let currentViewController = uiViewController.viewControllers?.first as? UIHostingController<IdentifiableContent<Content, S>>
        let currentIndex = currentViewController?.rootView.index ?? .origin

        if currentPage != currentIndex {
            let direction: UIPageViewController.NavigationDirection = currentPage > currentIndex ? .forward : .reverse
            let newViewController = UIHostingController(rootView: IdentifiableContent(index: currentPage, content: { content(currentPage) }))
            uiViewController.setViewControllers([newViewController], direction: direction, animated: true, completion: nil)
        }
    }

    class Coordinator: NSObject, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
        var parent: PagedInfiniteScrollView

        init(_ parent: PagedInfiniteScrollView) {
            self.parent = parent
        }

        func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
            guard let currentView = viewController as? UIHostingController<IdentifiableContent<Content, S>>, let currentIndex = currentView.rootView.index as S? else {
                return nil
            }

            let previousIndex = currentIndex.backward()

            return UIHostingController(rootView: IdentifiableContent(index: previousIndex, content: { parent.content(previousIndex) }))
        }

        func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
            guard let currentView = viewController as? UIHostingController<IdentifiableContent<Content, S>>, let currentIndex = currentView.rootView.index as S? else {
                return nil
            }

            let nextIndex = currentIndex.forward()

            return UIHostingController(rootView: IdentifiableContent(index: nextIndex, content: { parent.content(nextIndex) }))
        }

        func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
            if completed,
               let currentView = pageViewController.viewControllers?.first as? UIHostingController<IdentifiableContent<Content, S>>,
               let currentIndex = currentView.rootView.index as S? {
                parent.currentPage = currentIndex
            }
        }
    }
}

extension PagedInfiniteScrollView {
    struct IdentifiableContent<ContentView: View, Step: Steppable>: View {
        let index: Step
        let content: ContentView

        init(index: Step, @ViewBuilder content: () -> ContentView) {
            self.index = index
            self.content = content()
        }

        var body: some View {
            content
        }
    }
}
