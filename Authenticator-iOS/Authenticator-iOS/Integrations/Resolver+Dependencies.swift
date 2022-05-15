//
//  Resolver+Dependencies.swift
//  Authenticator-iOS
//
//  Created by Kertész Jenő Ármin on 2022. 05. 14..
//

import Foundation
import Resolver
import Combine

import FileSystemPersistentStorage
import AccountRepository

extension Resolver {
    static func registerDependencies() {
        register {
            JSONFileSystemPersistance<[Account]>(fileName: "accounts", queue: Queues.fileIOBackgroundQueue)
        }
        .implements(AccountRepositoryProvider.self)
        .scope(.cached)

        register { resolver in
            AccountRepository(provider: resolver.resolve())
        }
        .scope(.cached)

        register(TOTPProvider.self) {
            AuthenticatorTOTPProvider()
        }
    }
}
