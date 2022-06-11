//
//  FileSystemPersistentStorage+Extensions.swift
//  Authenticator-iOS
//
//  Created by Kertész Jenő Ármin on 2022. 05. 14..
//

import FileSystemPersistentStorage
import AccountRepository
import Foundation
import AuthenticatorListBusiness

extension JSONFileSystemPersistance: RepositoryProvider where T == [AuthenticatorAccountModel] {
    public typealias Item = AuthenticatorAccountModel

    public func save(items: [AuthenticatorAccountModel]) throws {
        try save(items)
    }

    public func readItems() throws -> [AuthenticatorAccountModel] {
        try read()
    }
}
