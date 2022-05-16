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

extension SceneDelegate {
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

    func handleListEvent(_ event: ListEvent, listViewController: AuthenticatorListViewController) {
        switch event {
        case .addAccountDidPress:
            let addAccountViewController = self.makeAddAccountViewController().embeddedInNavigationController
            addAccountViewController.modalPresentationStyle = .fullScreen
            listViewController.present(addAccountViewController, animated: true)
        default:
            break
        }
    }

    var listDependencies: ListComposer.Dependencies {
        .init(
            totpProvider: Resolver.resolve(),
            readAccounts: Resolver.resolve(AccountRepository.self).loadPublisher,
            delete: deletePublisher,
            appEventPublisher: Resolver.resolve())
    }

    func makeListViewController() -> AuthenticatorListViewController {
        let dependencies = listDependencies
        let listEventSubject = PassthroughSubject<ListEvent, Never>()
        let viewController = ListComposer.list(dependencies: dependencies, output: listEventSubject)
        listEventSubscription = listEventSubject
            .trackListEvents()
            .receive(on: DispatchQueue.main)
            .sink {
                self.handleListEvent($0, listViewController: viewController)
            }
        return viewController
    }
}
