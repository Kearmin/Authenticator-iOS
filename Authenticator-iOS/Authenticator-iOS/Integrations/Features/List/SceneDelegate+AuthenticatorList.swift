//
//  SceneDelegate+AuthenticatorList.swift
//  Authenticator-iOS
//
//  Created by Kertész Jenő Ármin on 2022. 05. 14..
//

import Combine
import AuthenticatorListView
import AccountRepository
import Resolver
import UIKit

extension SceneDelegate {
    func handleListEvent(_ event: ListEvent, listViewController: AuthenticatorListViewController?) {
        switch event {
        case .addAccountDidPress:
            let addAccountViewController = self.makeAddAccountViewController().embeddedInNavigationController
            addAccountViewController.modalPresentationStyle = .fullScreen
            listViewController?.present(addAccountViewController, animated: true)
        default:
            break
        }
    }

    var deletePublisher: (UUID) -> AnyPublisher<Void, Error> {
        { uuid in
            Resolver.resolve(AccountRepository.self)
                .deletePublisher(accountID: uuid)
                .handleEvents(receiveOutput: { _ in
                    Resolver.resolve(AuthenticatorAnalytics.self).track(name: "Did delete account")
                })
                .eraseToAnyPublisher()
        }
    }

    var listDependencies: ListComposer.Dependencies {
        let repository: AccountRepository = Resolver.resolve()
        return .init(
            totpProvider: Resolver.resolve(),
            readAccounts: repository.loadPublisher,
            delete: deletePublisher,
            moveAccounts: repository.movePublisher(fromID:toID:),
            refreshPublisher: repository.didSavePublisher)
    }

    func makeListViewController() -> AuthenticatorListViewController {
        let (viewController, listEventPublisher) = ListComposer.list(dependencies: listDependencies)
        listEventPublisher
            .trackListEvents()
            .receive(on: DispatchQueue.main)
            .sink { [weak viewController] in
                self.handleListEvent($0, listViewController: viewController)
            }
            .store(in: &subscriptions)
        return viewController
    }

    func makeListWindow(with windowScene: UIWindowScene) -> UIWindow {
        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = makeListViewController().embeddedInNavigationController
        return window
    }
}
