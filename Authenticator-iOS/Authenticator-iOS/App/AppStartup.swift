//
//  AppStartup.swift
//  Authenticator-iOS
//
//  Created by Kertész Jenő Ármin on 2022. 06. 06..
//

import Resolver

class AppStartup {
    let migrationRunner: FileSystemPersistentStorageMigrationRunner

    init() {
        Resolver.registerDependencies()
        migrationRunner = Resolver.resolve()
    }

    func runStartup() {
        migrationRunner.runMigrations()
    }
}
