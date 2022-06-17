//
//  UIKitHelpers.swift
//  Authenticator-iOSIntegrationTests
//
//  Created by Kertész Jenő Ármin on 2022. 06. 11..
//

import UIKit
import XCTest

extension UIBarButtonItem {
    var systemItem: SystemItem? {
        (value(forKey: "systemItem") as? NSNumber).flatMap { SystemItem(rawValue: $0.intValue) }
    }

    func simulateTap() {
        (target as? NSObject)?.perform(action)
    }
}

extension UIControl {
    func simulate(event: UIControl.Event) {
        allTargets.forEach { target in
            actions(forTarget: target, forControlEvent: event)?.forEach {
                (target as NSObject).perform(Selector($0))
            }
        }
    }
}

class ViewControllerSpy: UIViewController {
    var capturedViewController: UIViewController?

    var capturedNavigationController: UINavigationController? {
        capturedViewController as? UINavigationController
    }

    var capturedRootViewController: UIViewController? {
        capturedNavigationController?.viewControllers.first
    }

    override func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
        capturedViewController = viewControllerToPresent
    }

    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        XCTAssertNotNil(capturedViewController, "Dismiss called on non presenting viewcontroller")
        capturedViewController = nil
    }
}
