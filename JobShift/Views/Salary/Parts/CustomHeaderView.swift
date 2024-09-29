//
//  View+customHeaderView.swift
//  Atwy
//
//  Created by Antoine Bollengier on 14.03.2024.
//  Copyright © 2024 Antoine Bollengier. All rights reserved.
//

import SwiftUI

public extension View {
    /// add header under the navigation bar
    @ViewBuilder func customHeaderView<Content: View>(@ViewBuilder _ headerView: @escaping () -> Content, height: CGFloat) -> some View {
        overlay(content: {
            CustomNavigationHeaderView(headerView: headerView, height: height)
                .frame(width: 0, height: 0)
        })
    }
}
public struct CustomNavigationHeaderView<HeaderView: View>: UIViewControllerRepresentable {
    @ViewBuilder public var headerView: () -> HeaderView
    let height: CGFloat
    
    public func makeUIViewController(context: Context) -> UIViewController {
        return ViewControllerWrapper(headerView: headerView, height: height)
    }
    
    class ViewControllerWrapper: UIViewController {
        let headerView: () -> HeaderView
        let height: CGFloat
        var isInitial = true
                
        init(headerView: @escaping () -> HeaderView, height: CGFloat) {
            self.headerView = headerView
            self.height = height
            super.init(nibName: nil, bundle: nil)
            // buttomSheetHelperのsheetが開いている状態では表示されないので完全に閉じるのを待つ
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                self.isInitial = false
                self.setHeaderView()
            }
        }
        
        override func viewWillAppear(_ animated: Bool) {
            setHeaderView()
            super.viewWillAppear(animated)
        }
        
        private func setHeaderView() {
            guard !isInitial else { return }
            guard let navigationController = self.navigationController, let navigationItem = navigationController.visibleViewController?.navigationItem else { return }
            
            // a trick from https://x.com/sebjvidal/status/1748659522455937213
            
            let _UINavigationBarPalette = NSClassFromString("_UINavigationBarPalette") as! UIView.Type
            
            let castedHeaderView = UIHostingController(rootView: self.headerView()).view
            castedHeaderView?.frame.size.height = height
            castedHeaderView?.backgroundColor = .clear
            
            let palette = _UINavigationBarPalette.perform(NSSelectorFromString("alloc"))
                .takeUnretainedValue()
                .perform(NSSelectorFromString("initWithContentView:"), with: castedHeaderView)
                .takeUnretainedValue()
            
            UIView.transition(with: navigationController.navigationBar, duration: 0.3, options: .transitionCrossDissolve, animations: {
                navigationItem.perform(NSSelectorFromString("_setBottomPalette:"), with: palette)
            }, completion: nil)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
    
    public func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}
