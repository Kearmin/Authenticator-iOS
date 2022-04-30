//
//  FileSystemPersistentStorageComposer.swift
//  Authenticator-iOS
//
//  Created by Kertész Jenő Ármin on 2022. 04. 24..
//

import FileSystemPersistentStorage
import AccountRepository

extension JSONFileSystemPersistance: AccountRepositoryProvider where T == [Account] {
    public func save(accounts: [Account]) throws {
        try self.save(accounts)
    }

    public func readAccounts() throws -> [Account] {
        try read()
    }
}
