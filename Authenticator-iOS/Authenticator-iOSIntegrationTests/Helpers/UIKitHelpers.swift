//
//  UIKitHelpers.swift
//  Authenticator-iOSIntegrationTests
//
//  Created by Kertész Jenő Ármin on 2022. 06. 11..
//

import UIKit

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
