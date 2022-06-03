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

//        register(SegmentAnalytics.self) {
//            SegmentAnalytics()
//        }
//        .implements(AuthenticatorAnalytics.self)
//        .scope(.application)

        register(JSONFileSystemPersistance<[AuthenticatorAccountModel]>.self) { resolver in
            let analytics: AuthenticatorAnalytics = resolver.resolve()
            let userDefaults: UserDefaults = resolver.resolve()
            if userDefaults.object(forKey: Keys.accountMigrations) == nil {
                userDefaults.set(Constants.accountVersion, forKey: Keys.accountMigrations)
            }
            let accountPersistance = JSONFileSystemPersistance<[AuthenticatorAccountModel]>(
                fileName: "accounts",
                queue: Queues.fileIOBackgroundQueue,
                version: userDefaults.integer(forKey: Keys.accountMigrations))
            do {
                let migrationsRan = try accountPersistance.runMigrations([AddFavouriteMigration()])
                if migrationsRan > 0 {
                    UserDefaults.standard.set(Constants.accountVersion, forKey: Keys.accountMigrations)
                    analytics.track(name: "Successfully ran migrations")
                } else {
                    print("No eligible migrations ran")
                }
            } catch {
                analytics.track(name: "Failed to run migrations", properties: ["Error": error])
            }
            return accountPersistance
        }
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
