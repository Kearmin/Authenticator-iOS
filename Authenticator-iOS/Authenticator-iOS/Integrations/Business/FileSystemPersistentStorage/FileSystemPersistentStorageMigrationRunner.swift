//
//  MigrationRunner.swift
//  Authenticator-iOS
//
//  Created by Kertész Jenő Ármin on 2022. 06. 06..
//

import Foundation
import FileSystemPersistentStorage
import Resolver

class FileSystemPersistentStorageMigrationRunner {
    private let persistance: AccountJSONFileSystemPersistance
    private let analytics: AuthenticatorAnalytics
    private let userDefaults: UserDefaults
    private let migrations: [JSONFileSystemPersistanceMigration]

    init(
        migrations: [JSONFileSystemPersistanceMigration],
        persistance: AccountJSONFileSystemPersistance,
        analytics: AuthenticatorAnalytics,
        userDefaults: UserDefaults
    ) {
        self.persistance = persistance
        self.analytics = analytics
        self.userDefaults = userDefaults
        self.migrations = migrations
    }

    func runMigrations() {
        if userDefaults.object(forKey: Keys.accountMigrations) == nil {
            userDefaults.set(Constants.accountVersion, forKey: Keys.accountMigrations)
        }
        do {
            let migrationsRan = try persistance.runMigrations(migrations)
            if migrationsRan > 0 {
                userDefaults.set(Constants.accountVersion, forKey: Keys.accountMigrations)
                analytics.track(name: "Successfully ran migrations")
            } else {
                print("No eligible migrations ran")
            }
        } catch {
            analytics.track(name: "Failed to run migrations", properties: ["Error": error])
        }
    }
}
