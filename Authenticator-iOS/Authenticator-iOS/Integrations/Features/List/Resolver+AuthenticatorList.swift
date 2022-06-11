//
//  SceneDelegate+AuthenticatorList.swift
//  Authenticator-iOS
//
//  Created by Kertész Jenő Ármin on 2022. 05. 14..
//

import Combine
import AuthenticatorListView
import Repository
import Resolver
import Clock
import UIKit

extension Resolver {
    static func registerListDependencies() {
        register(ListComposer.Dependencies.self) { resolver in
            let repository: AccountRepository = resolver.resolve()
            let clock: Clock = resolver.resolve()
            return .init(
                totpProvider: resolver.resolve(),
                readAccounts: repository.loadPublisher,
                delete: deletePublisher(repository: repository),
                favourite: repository.favourite(_:),
                update: repository.update(_:),
                refreshPublisher: repository.didSavePublisher,
                clockPublisher: clock.clockPublisher,
                analytics: resolver.resolve())
        }
    }

    static func deletePublisher(repository: AccountRepository) -> (UUID) -> AnyPublisher<Void, Error> {
        { uuid in
            repository
                .deletePublisher(accountID: uuid)
                .handleEvents(receiveOutput: { _ in
                    Resolver.resolve(AuthenticatorAnalytics.self).track(name: "Did delete account")
                })
                .eraseToAnyPublisher()
        }
    }
}
