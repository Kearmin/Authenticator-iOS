//
//  SceneDelegate.swift
//  Authenticator-iOS
//
//  Created by Kertész Jenő Ármin on 2022. 05. 14..
//

import UIKit
import Resolver
import AuthenticatorListView
import Combine

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    var subscriptions = Set<AnyCancellable>()
    var overlayFlow: OverlayFlow?

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
        let overlayFlow = OverlayFlow(appWindow: makeListWindow(with: windowScene), sceneDelegate: self)
        overlayFlow.start(with: windowScene)
    }

    func unitTestScene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // No setup if running unit tests
    }
}
