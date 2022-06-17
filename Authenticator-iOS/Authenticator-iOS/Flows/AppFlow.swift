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

class AppFlow {
    private let overlayFlow: OverlayFlow
    private let addAccountFlow: AddAccountFlow
    private let listFactory: ListFactory
    private var listEventCancellable: AnyCancellable?

    init(
        listFactory: @escaping ListFactory,
        overlayFlow: OverlayFlow,
        addAccountFlow: AddAccountFlow
    ) {
        self.listFactory = listFactory
        self.overlayFlow = overlayFlow
        self.addAccountFlow = addAccountFlow
    }

    func start(with windowScene: UIWindowScene, sceneDelegate: SceneDelegate) {
        overlayFlow.start(
            with: windowScene,
            appWindow: makeListWindow(with: windowScene),
            sceneDelegate: sceneDelegate)
    }
}

private extension AppFlow {
    func makeListWindow(with windowScene: UIWindowScene) -> UIWindow {
        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = makeListViewController().embeddedInNavigationController
        return window
    }

    func makeListViewController() -> AuthenticatorListViewController {
        let (viewController, listEventPublisher) = listFactory()
        listEventCancellable = listEventPublisher
            .sink { [weak viewController] in
                self.handleListEvent($0, listViewController: viewController)
            }
        return viewController
    }

    func handleListEvent(_ event: ListEvent, listViewController: AuthenticatorListViewController?) {
        switch event {
        case .addAccountDidPress:
            addAccountFlow.start(with: listViewController)
        case .deleteAccountDidPress(let context):
            DeleteAccountFlow().start(context: context, source: listViewController)
        case .editDidPress(let context):
            EditAccountFlow().start(context: context, source: listViewController)
        case .onError(let context):
            ShowErrorFlow().start(context: context, source: listViewController)
        default:
            break
        }
    }
}
