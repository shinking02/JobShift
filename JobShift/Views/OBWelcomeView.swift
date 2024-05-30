import SwiftUI
import UIKit

// this trick from https://qiita.com/SNQ-2001/items/007cc722b38883d32a23

struct OBWelcomeView: UIViewControllerRepresentable {
    private let title: NSString
    private let detailText: NSString
    private let symbolName: NSString?
    private let bulletedListItems: [OBWelcomeController.OBWelcomeBulletedListItem]
    private let boldButtonItem: OBWelcomeController.OBWelcomeButtonItem
    private let linkButtonItem: OBWelcomeController.OBWelcomeButtonItem?
    
    init(
        title: NSString,
        detailText: NSString,
        symbolName: NSString? = nil,
        bulletedListItems: [OBWelcomeController.OBWelcomeBulletedListItem],
        boldButtonItem: OBWelcomeController.OBWelcomeButtonItem,
        linkButtonItem: OBWelcomeController.OBWelcomeButtonItem? = nil
    ) {
        self.title = title
        self.detailText = detailText
        self.symbolName = symbolName
        self.bulletedListItems = bulletedListItems
        self.boldButtonItem = boldButtonItem
        self.linkButtonItem = linkButtonItem
    }
    
    func makeUIViewController(context: Context) -> UIViewController {
        let welcomeController = OBWelcomeController(
            title: title,
            detailText: detailText,
            symbolName: symbolName
        )
        
        bulletedListItems.forEach { bulletedListItem in
            welcomeController.addBulletedListItem(
                title: bulletedListItem.title,
                description: bulletedListItem.description,
                symbolName: bulletedListItem.symbolName
            )
        }
        
        welcomeController.addBoldButton(title: boldButtonItem.title, action: boldButtonItem.action)
        
        if let linkButtonItem {
            welcomeController.addLinkButton(title: linkButtonItem.title, action: linkButtonItem.action)
        }
        
        return welcomeController.viewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}

class OBWelcomeController {
    private(set) var viewController: UIViewController!
    private let frameworkPath = "/System/Library/PrivateFrameworks/OnBoardingKit.framework/OnBoardingKit"
    
    init(
        title: NSString,
        detailText: NSString,
        symbolName: NSString?
    ) {
        dlopen(frameworkPath, RTLD_NOW)
        
        let initWithTitleDetailTextSymbolName = (@convention(c) (NSObject, Selector, NSString, NSString, NSString?) -> UIViewController).self
        
        let OBWelcomeController = NSClassFromString("OBWelcomeController") as! NSObject.Type
        let welcomeController = OBWelcomeController
            .perform(NSSelectorFromString("alloc"))
            .takeUnretainedValue() as! NSObject
        
        let selector = NSSelectorFromString("initWithTitle:detailText:symbolName:")
        let implementation = welcomeController.method(for: selector)
        let method = unsafeBitCast(implementation, to: initWithTitleDetailTextSymbolName.self)

        viewController = method(welcomeController, selector, title, detailText, symbolName)
    }
    
    func addBulletedListItem(
        title: NSString,
        description: NSString,
        symbolName: NSString,
        tintColor: UIColor = .tintColor
    ) {
        let addBulletedListItemWithTitleDescriptionSymbolNameTintColor = (@convention(c) (NSObject, Selector, NSString, NSString, NSString, UIColor) -> Void).self
        let selector = NSSelectorFromString("addBulletedListItemWithTitle:description:symbolName:tintColor:")
        let implementation = viewController.method(for: selector)
        let method = unsafeBitCast(implementation, to: addBulletedListItemWithTitleDescriptionSymbolNameTintColor.self)
        _ = method(viewController, selector, title, description, symbolName, tintColor)
    }
    
    func addBoldButton(
        title: NSString,
        action: @escaping () -> Void
    ) {
        let OBBoldTrayButton = NSClassFromString("OBBoldTrayButton") as! NSObject.Type
        let selector = NSSelectorFromString("boldButton")
        let button = OBBoldTrayButton.perform(selector).takeUnretainedValue() as! UIButton
        button.configuration?.title = String(title)
        button.addAction(UIAction { _ in action() }, for: .touchUpInside)
        
        let buttonTray = viewController.value(forKey: "buttonTray") as! NSObject
        buttonTray.perform(NSSelectorFromString("addButton:"), with: button)
    }
    
    func addLinkButton(
        title: NSString,
        action: @escaping () -> Void
    ) {
        let OBLinkTrayButton = NSClassFromString("OBLinkTrayButton") as! NSObject.Type
        let selector = NSSelectorFromString("linkButton")
        let button = OBLinkTrayButton.perform(selector).takeUnretainedValue() as! UIButton
        button.configuration?.title = String(title)
        button.addAction(UIAction { _ in action() }, for: .touchUpInside)
        
        let buttonTray = viewController.value(forKey: "buttonTray") as! NSObject
        buttonTray.perform(NSSelectorFromString("addButton:"), with: button)
    }
}

extension OBWelcomeController {
    struct OBWelcomeBulletedListItem {
        let title: NSString
        let description: NSString
        let symbolName: NSString
        
        init(
            title: NSString,
            description: NSString,
            symbolName: NSString
        ) {
            self.title = title
            self.description = description
            self.symbolName = symbolName
        }
    }
}

extension OBWelcomeController {
    struct OBWelcomeButtonItem {
        let title: NSString
        let action: () -> Void
    }
}
