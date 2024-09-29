//
//  CustomNavigationTitle.swift
//  Atwy
//
//  Created by Antoine Bollengier on 16.11.2023.
//

import SwiftUI

public extension View {
    /// add icon to navigation title
    @ViewBuilder func customNavigationTitleWithRightIcon<Content: View>(@ViewBuilder _ rightIcon: @escaping () -> Content) -> some View {
        overlay(content: {
            CustomNavigationTitleView(rightIcon: rightIcon)
                .frame(width: 0, height: 0)
        })
    }
}

public struct CustomNavigationTitleView<RightIcon: View>: UIViewControllerRepresentable {
    @ViewBuilder public var rightIcon: () -> RightIcon
    
    public func makeUIViewController(context: Context) -> UIViewController {
        return ViewControllerWrapper(rightContent: rightIcon)
    }
    
    class ViewControllerWrapper: UIViewController {
        var rightContent: () -> RightIcon
        var isInitial = true
                
        init(rightContent: @escaping () -> RightIcon) {
            self.rightContent = rightContent
            super.init(nibName: nil, bundle: nil)
            // buttomSheetHelperのsheetが開いている状態では表示されないので完全に閉じるのを待つ
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                self.isInitial = false
                self.setRightIcon(animation: true)
            }
        }
        
        override func viewWillAppear(_ animated: Bool) {
            setRightIcon(animation: false)
            super.viewWillAppear(animated)
        }
        
        private func setRightIcon(animation: Bool) {
            guard !isInitial else { return }
            guard let navigationController = self.navigationController, let navigationItem = navigationController.visibleViewController?.navigationItem else { return }
            
            let contentView = UIHostingController(rootView: rightContent())
            contentView.view.backgroundColor = .clear
            
            UIView.transition(with: navigationController.navigationBar, duration: animation ? 0.3 : 0, options: .transitionCrossDissolve, animations: {
                // https://github.com/sebjvidal/UINavigationItem-LargeTitleAccessoryView-Demo
                navigationItem.perform(Selector(("_setLargeTitleAccessoryView:")), with: contentView.view)
                navigationItem.setValue(false, forKey: "_alignLargeTitleAccessoryViewToBaseline")
                navigationController.navigationBar.prefersLargeTitles = true
            }, completion: nil)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
    
    public func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}
