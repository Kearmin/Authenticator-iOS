//
//  AppStartup.swift
//  Authenticator-iOS
//
//  Created by Kertész Jenő Ármin on 2022. 06. 06..
//

import Resolver

class AppStartup {
    let segmentAnalytics: SegmentAnalytics?
    let migrationRunner: FileSystemPersistentStorageMigrationRunner

    init() {
        Resolver.registerDependencies()
        segmentAnalytics = Resolver.optional()
        migrationRunner = Resolver.resolve()
    }

    func runStartup() {
        segmentAnalytics?.initialize()
        migrationRunner.runMigrations()
    }
}
