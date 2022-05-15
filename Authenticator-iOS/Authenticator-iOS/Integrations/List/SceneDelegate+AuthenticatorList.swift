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

    var listDependencies: ListComposer.Dependencies {
        let subject = PassthroughSubject<AuthenticatorListViewController, Never>()
        didPressAddAccountSubscription = subject.sink(receiveValue: listViewControllerDidPress)
        return .init(
            didPressAddAccount: subject,
            totpProvider: Resolver.resolve(),
            readAccounts: Resolver.resolve(AccountRepository.self).loadPublisher,
            delete: deletePublisher,
            appEventPublisher: Resolver.resolve())
    }

    var listViewControllerDidPress: (AuthenticatorListViewController) -> Void {
        { listViewController in
            let addAccountViewController = self.makeAddAccountViewController().embeddedInNavigationController
            addAccountViewController.modalPresentationStyle = .fullScreen
            listViewController.present(addAccountViewController, animated: true)
        }
    }
}
