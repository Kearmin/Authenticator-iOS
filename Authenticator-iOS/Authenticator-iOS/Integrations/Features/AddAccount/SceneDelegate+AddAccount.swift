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

extension SceneDelegate {
    var addAccountDependencies: AddAccountComposer.Dependencies {
        .init(
            saveAccountPublisher: Resolver.resolve(AccountRepository.self).savePublisher(account:))
    }
}
