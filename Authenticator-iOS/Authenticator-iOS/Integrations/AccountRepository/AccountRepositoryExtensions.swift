//
//  AccountRepositoryExtensions.swift
//  Authenticator-iOS
//
//  Created by Kertész Jenő Ármin on 2022. 05. 14..
//

import Combine
import AccountRepository

extension AccountRepository {
    func loadPublisher() -> AnyPublisher<[Account], Never> {
        Just(self.readAccounts()).eraseToAnyPublisher()
    }

    func deletePublisher(accountID: UUID) -> AnyPublisher<Void, Error> {
        Future { completion in
            completion(Result { try self.delete(accountID: accountID) })
        }
        .eraseToAnyPublisher()
    }

    func savePublisher(account: Account) -> AnyPublisher<Void, Error> {
        Future { completion in
            completion(Result { try self.add(account: account) })
        }
        .eraseToAnyPublisher()
    }
}
