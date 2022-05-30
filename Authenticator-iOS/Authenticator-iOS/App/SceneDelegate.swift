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
        if AppConfig.isRunningUnitTests {
            unitTestScene(scene, willConnectTo: session, options: connectionOptions)
        } else {
            appScene(scene, willConnectTo: session, options: connectionOptions)
        }
    }

    func appScene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        Resolver.registerDependencies()
        Resolver.optional(SegmentAnalytics.self)?.initialize()

        guard let windowScene = (scene as? UIWindowScene) else { return }
        overlayWindow = makeOverlayWindow(with: windowScene)
        appWindow = makeListWindow(with: windowScene)
        window = overlayWindow
        window?.makeKeyAndVisible()
    }

    func unitTestScene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // No setup if running unit tests
    }
}
