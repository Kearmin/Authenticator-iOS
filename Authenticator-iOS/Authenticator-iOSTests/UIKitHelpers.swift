//
//  UIKitHelpers.swift
//  Authenticator-iOSTests
//
//  Created by Kertész Jenő Ármin on 2022. 05. 01..
//

import UIKit

extension UIViewController {
    func triggerLifecycleIfNeeded() {
        guard !isViewLoaded else { return }

        loadViewIfNeeded()
        beginAppearanceTransition(true, animated: false)
        endAppearanceTransition()
    }
}

extension RunLoop {
    func runUntilCurrentDate() {
        run(until: Date())
    }
}

extension UIBarButtonItem {
    var systemItem: SystemItem? {
        (value(forKey: "systemItem") as? NSNumber).flatMap { SystemItem(rawValue: $0.intValue) }
    }

    func simulateTap() {
        (target as? NSObject)?.perform(action)
    }
}
