//
//  FileSystemPersistentStorage+Extensions.swift
//  Authenticator-iOS
//
//  Created by Kertész Jenő Ármin on 2022. 05. 14..
//

import FileSystemPersistentStorage
import AccountRepository

extension JSONFileSystemPersistance: AccountRepositoryProvider where T == [Account] {
    public func readAccounts() throws -> [Account] {
        try read()
    }

    public func save(accounts: [Account]) throws {
        try save(accounts)
    }
}
