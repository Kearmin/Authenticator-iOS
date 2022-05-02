//
//  AccountRepositoryComposer.swift
//  Authenticator-iOS
//
//  Created by Kertész Jenő Ármin on 2022. 04. 24..
//

import AccountRepository
import FileSystemPersistentStorage
import AddAccountBusiness


extension AccountRepository: AddAccountSaveService {
    public func save(account: CreatAccountModel) throws {
        try add(account: account.asAccount)
    }
}

private extension CreatAccountModel {
    var asAccount: Account {
        .init(id: UUID(), issuer: issuer, secret: secret, username: username)
    }
}
