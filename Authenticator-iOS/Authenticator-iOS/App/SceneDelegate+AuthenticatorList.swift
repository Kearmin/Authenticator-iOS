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
    var listDependencies: ListComposer.Dependencies {
        let subject = PassthroughSubject<AuthenticatorListViewController, Never>()
        didPressAddAccountSubscription = subject.sink(receiveValue: listViewControllerDidPress)
        let accountRepository: AccountRepository = Resolver.resolve()
        return .init(
            didPressAddAccount: subject,
            totpProvider: Resolver.resolve(),
            readAccounts: accountRepository.loadPublisher,
            delete: accountRepository.deletePublisher(accountID:),
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
