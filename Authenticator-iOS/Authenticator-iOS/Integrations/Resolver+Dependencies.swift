//
//  Resolver+Dependencies.swift
//  Authenticator-iOS
//
//  Created by Kertész Jenő Ármin on 2022. 05. 14..
//

import Foundation
import Resolver
import Combine
import Clock

import FileSystemPersistentStorage
import AccountRepository
import AuthenticatorListBusiness
import UIKit

extension Resolver {
    static func registerDependencies() {
        register(AuthenticatorAnalytics.self) {
            if AppConfig.isDebug {
                return LogAnalytics()
            } else {
                return SegmentAnalytics()
            }
        }
        .scope(.application)

        register {
            UserDefaults.standard
        }
        .scope(.application)

        register {
            AppFlow()
        }
        .scope(.cached)

        register {
            Clock()
        }
        .scope(.cached)

        register(AccountJSONFileSystemPersistance.self) { resolver in
            let userDefaults: UserDefaults = resolver.resolve()
            return AccountJSONFileSystemPersistance(
                fileName: Constants.accountsFileName,
                queue: Queues.fileIOBackgroundQueue,
                version: userDefaults.integer(forKey: Keys.accountMigrations))
        }
        .scope(.cached)

        register { resolver in
            AccountRepository(provider: resolver.resolve())
        }
        .scope(.cached)

        register { resolver in
            FileSystemPersistentStorageMigrationRunner(
                persistance: resolver.resolve(),
                analytics: resolver.resolve(),
                userDefaults: resolver.resolve())
        }

        register(AuthenticatorTOTPProvider.self) {
            SwiftOTPTOTPProvider()
        }

        registerFeatureDependencies()
    }

    static func registerFeatureDependencies() {
        registerListDependencies()
        registerAddAccountDependencies()
    }
}
