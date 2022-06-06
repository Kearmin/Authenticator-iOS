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
import AuthenticatorListBusiness
import UIKit

extension Resolver {
    static func registerDependencies() {
        register {
            LogAnalytics()
        }
        .implements(AuthenticatorAnalytics.self)
        .scope(.application)

        register {
            UserDefaults.standard
        }
        .scope(.application)

        register {
            AppFlow()
        }
        .scope(.application)

//        register(SegmentAnalytics.self) {
//            SegmentAnalytics()
//        }
//        .implements(AuthenticatorAnalytics.self)
//        .scope(.application)

        register(AccountJSONFileSystemPersistance.self) { resolver in
            let userDefaults: UserDefaults = resolver.resolve()
            return AccountJSONFileSystemPersistance(
                fileName: "accounts",
                queue: Queues.fileIOBackgroundQueue,
                version: userDefaults.integer(forKey: Keys.accountMigrations))
        }
        .scope(.cached)

        register { resolver in
            FileSystemPersistentStorageMigrationRunner(
                persistance: resolver.resolve(),
                analytics: resolver.resolve(),
                userDefaults: resolver.resolve())
        }

        register { resolver in
            AccountRepository(provider: resolver.resolve())
        }
        .scope(.cached)

        register(TOTPProvider.self) {
            AuthenticatorTOTPProvider()
        }

        registerFeatureDependencies()
    }

    static func registerFeatureDependencies() {
        registerListDependencies()
        registerAddAccountDependencies()
    }
}
