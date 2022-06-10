//
//  AppFlow.swift
//  Authenticator-iOS
//
//  Created by Kertész Jenő Ármin on 2022. 06. 06..
//

import Foundation
import UIKit
import Combine
import AuthenticatorListView
import Resolver

class AppFlow {
    var overlayFlow: OverlayFlow?
    var listEventCancellable: AnyCancellable?

    func start(with windowScene: UIWindowScene, sceneDelegate: SceneDelegate) {
        overlayFlow = .init(
            appWindow: makeListWindow(with: windowScene),
            sceneDelegate: sceneDelegate)
        overlayFlow?.start(with: windowScene)
    }

    func makeListWindow(with windowScene: UIWindowScene) -> UIWindow {
        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = makeListViewController().embeddedInNavigationController
        return window
    }

    func makeListViewController() -> AuthenticatorListViewController {
        let (viewController, listEventPublisher) = ListComposer.list(dependencies: Resolver.resolve())
        listEventCancellable = listEventPublisher
            .trackListEvents()
            .receive(on: DispatchQueue.main)
            .sink { [weak viewController] in
                self.handleListEvent($0, listViewController: viewController)
            }
        return viewController
    }

    func handleListEvent(_ event: ListEvent, listViewController: AuthenticatorListViewController?) {
        switch event {
        case .addAccountDidPress:
            let addAccountFlow = AddAccountFlow(source: listViewController)
            addAccountFlow.start(dependencies: Resolver.resolve())
        case .deleteAccountDidPress(let context):
            let deleteAccountFlow = DeleteAccountFlow(source: listViewController, didPressDelete: context.callback)
            deleteAccountFlow.start()
        case .editDidPress(let context):
            let editFlow = EditAccountFlow(account: context.item, source: listViewController, didFinishUpdate: context.callback)
            editFlow.start()
        default:
            break
        }
    }
}
