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

extension Resolver {
    static func registerListDependencies() {
        register(ListComposer.Dependencies.self) { resolver in
            let repository: AccountRepository = resolver.resolve()
            return .init(
                totpProvider: resolver.resolve(),
                readAccounts: repository.loadPublisher,
                delete: deletePublisher,
                moveAccounts: repository.movePublisher(fromID:toID:),
                favourite: repository.favourite(_:),
                update: repository.update(_:),
                refreshPublisher: repository.didSavePublisher)
        }
    }

    static var deletePublisher: (UUID) -> AnyPublisher<Void, Error> {
        { uuid in
            Resolver.resolve(AccountRepository.self)
                .deletePublisher(accountID: uuid)
                .handleEvents(receiveOutput: { _ in
                    Resolver.resolve(AuthenticatorAnalytics.self).track(name: "Did delete account")
                })
                .eraseToAnyPublisher()
        }
    }
}
