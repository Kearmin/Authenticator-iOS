//
//  SceneDelegate+AddAccount.swift
//  Authenticator-iOS
//
//  Created by Kertész Jenő Ármin on 2022. 05. 14..
//

import Combine
import AddAccountView
import AccountRepository
import Resolver
import UIKit

extension Resolver {
    static func registerAddAccountDependencies() {
        register(AddAccountComposer.Dependencies.self) { resolver in
            .init(
                saveAccountPublisher: resolver.resolve(AccountRepository.self).savePublisher(account:),
                analytics: resolver.resolve())
        }
    }
}
