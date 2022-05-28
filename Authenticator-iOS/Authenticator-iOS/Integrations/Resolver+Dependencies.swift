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
import UIKit

extension Resolver {
    static func registerDependencies() {
        register {
            LogAnalytics()
        }
        .implements(AuthenticatorAnalytics.self)
        .scope(.application)

//        register(SegmentAnalytics.self) {
//            SegmentAnalytics()
//        }
//        .implements(AuthenticatorAnalytics.self)
//        .scope(.application)

        register(AppEventSubject.self) {
            PassthroughSubject<AppEvent, Never>()
        }
        .scope(.application)

        register(AppEventPublisher.self) { resolver in
            let subject: AppEventSubject = resolver.resolve()
            return subject.eraseToAnyPublisher()
        }
        .scope(.application)

        register(JSONFileSystemPersistance<[Account]>.self) { resolver in
            let analytics: AuthenticatorAnalytics = resolver.resolve()
            if UserDefaults.standard.object(forKey: Keys.accountMigrations) == nil {
                UserDefaults.standard.set(Constants.accountVersion, forKey: Keys.accountMigrations)
            }
            let accountPersistance = JSONFileSystemPersistance<[Account]>(
                fileName: "accounts",
                queue: Queues.fileIOBackgroundQueue,
                version: UserDefaults.standard.integer(forKey: Keys.accountMigrations))
            do {
                let migrationsRun = try accountPersistance.runMigrations([AddFavouriteMigration()])
                if migrationsRun > 0 {
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
