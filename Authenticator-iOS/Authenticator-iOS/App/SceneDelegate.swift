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

    var didPressAddAccountSubscription: AnyCancellable?
    var addAccountEventSubscription: AnyCancellable?
    let appEventPublisher = PassthroughSubject<AppEvent, Never>()

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        let list = ListComposer.list(dependencies: listDependencies)
        window?.rootViewController = list.embeddedInNavigationController
        window?.makeKeyAndVisible()
    }
}
