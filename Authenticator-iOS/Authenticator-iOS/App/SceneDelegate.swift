//
//  SceneDelegate.swift
//  Authenticator-iOS
//
//  Created by Kertész Jenő Ármin on 2022. 05. 14..
//

import UIKit
import Resolver
import FileSystemPersistentStorage
import AccountRepository
import Combine
import AuthenticatorListView
import AddAccountView

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    var listEventSubscription: AnyCancellable?
    var addAccountEventSubscription: AnyCancellable?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        Resolver.registerDependencies()
        Resolver.optional(SegmentAnalytics.self)?.initialize()

        guard let windowScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = makeListViewController().embeddedInNavigationController
        window.makeKeyAndVisible()
        self.window = window
        Resolver.registerAppOverlayManager(with: windowScene, originalWindow: window, sceneDelegate: self)
    }
}
