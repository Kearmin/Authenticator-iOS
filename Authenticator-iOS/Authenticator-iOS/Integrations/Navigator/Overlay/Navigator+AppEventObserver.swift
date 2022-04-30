//
//  Navigator+AppEventObserver.swift
//  Authenticator-iOS
//
//  Created by Kertész Jenő Ármin on 2022. 04. 24..
//

import Foundation
import UIKit
import Resolver
import UIKitNavigator

extension UIKitNavigator: AppEventObserver {
    var overlayViewController: OverLayViewController { Resolver.resolve() }
    func handle(event: AppEvent) {
        switch event {
        case .appDidEnterForeground:
            overlayViewController.dismiss(animated: false)
        case .appWillEnterBackground:
            UIApplication.topViewController()?.present(overlayViewController, animated: false)
        }
    }
}

private extension UIApplication {
    class func topViewController() -> UIViewController? {
        let rootViewController = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.keyWindow?.rootViewController
        return topViewController(controller: rootViewController)
    }

    class func topViewController(controller: UIViewController?) -> UIViewController? {
        if let navigationController = controller as? UINavigationController {
            return topViewController(controller: navigationController.visibleViewController)
        }
        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return topViewController(controller: selected)
            }
        }
        if let presented = controller?.presentedViewController {
            return topViewController(controller: presented)
        }
        return controller
    }
}
