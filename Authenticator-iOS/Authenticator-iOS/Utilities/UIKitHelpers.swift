//
//  UIKitHelperes.swift
//  Authenticator-iOS
//
//  Created by Kertész Jenő Ármin on 2022. 05. 14..
//

import Foundation
import UIKit

extension UIViewController {
    var embeddedInNavigationController: UINavigationController {
        UINavigationController(rootViewController: self)
    }
}
