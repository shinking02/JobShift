import SwiftUI

extension View {
    @ViewBuilder
    func bottomMaskForSheet(_ height: CGFloat = 49) -> some View {
        self
            .background(SheetRootViewFinder(height: height))
    }
}

fileprivate struct SheetRootViewFinder: UIViewRepresentable {
    var height: CGFloat
    func makeCoordinator() -> Coordinator {
        return Coordinator()
    }
    
    func makeUIView(context: Context) -> UIView {
        return .init()
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            guard !context.coordinator.isMasked else { return }
            if let rootView = uiView.viewBeforeWindow {
                let safeArea = rootView.safeAreaInsets
                rootView.frame = .init(
                    origin: .zero,
                    size: .init(
                        width: rootView.frame.width,
                        height: rootView.frame.height - (height + safeArea.bottom)
                    )
                )
                
                rootView.clipsToBounds = true
                for view in rootView.subviews {
                    view.layer.shadowColor = UIColor.clear.cgColor
                    
                    if view.layer.animationKeys() != nil {
                        if let cornerRadiusView = view.allSubViews.first(where: {
                            $0.layer.animationKeys()?.contains("cornerRadius") ?? false }) {
                            cornerRadiusView.layer.maskedCorners = []
                        }
                    }
                }
                context.coordinator.isMasked = true
            }
        }
    }
    
    class Coordinator: NSObject {
        var isMasked: Bool = false
    }
}


fileprivate extension UIView {
    var viewBeforeWindow: UIView? {
        if let superview, superview is UIWindow {
            return self
        }
        return superview?.viewBeforeWindow
    }
    
    var allSubViews: [UIView] {
        return subviews.flatMap { [$0] + $0.subviews }
    }
}
