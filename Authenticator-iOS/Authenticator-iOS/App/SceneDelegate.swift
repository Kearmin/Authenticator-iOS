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
import OverlayView

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    var overlayWindow: UIWindow?
    var appWindow: UIWindow?
    var subscriptions = Set<AnyCancellable>()

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard !AppConfig.isRunningTests else { return }
        Resolver.registerDependencies()
        Resolver.optional(SegmentAnalytics.self)?.initialize()

        guard let windowScene = (scene as? UIWindowScene) else { return }
        overlayWindow = makeOverlayWindow(with: windowScene)
        appWindow = makeListWindow(with: windowScene)
        window = appWindow
        window?.makeKeyAndVisible()
    }
}
