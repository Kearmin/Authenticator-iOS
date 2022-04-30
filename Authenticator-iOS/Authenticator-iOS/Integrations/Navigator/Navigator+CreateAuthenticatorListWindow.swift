//
//  Navigator+CreateAuthenticatorListWindow.swift
//  Authenticator-iOS
//
//  Created by Kertész Jenő Ármin on 2022. 04. 24..
//

import UIKit
import UIKitNavigator
import AuthenticatorListView
import AuthenticatorListBusiness
import Resolver

extension UIKitNavigator {
    func createAuthenticatorListWindow(with windowScene: UIWindowScene) -> UIWindow {
        let window = UIWindow(windowScene: windowScene)
        let authenticatorList = AuthenticatorListComposer()
        authenticatorList.delegate = self
        showRootViewControllerEmbeddedInNavigationController(on: window, rootViewController: authenticatorList)
        return window
    }
}
