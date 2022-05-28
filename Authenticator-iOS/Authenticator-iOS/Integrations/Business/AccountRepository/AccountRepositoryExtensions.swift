//
//  AccountRepositoryExtensions.swift
//  Authenticator-iOS
//
//  Created by Kertész Jenő Ármin on 2022. 05. 14..
//

import Combine
import AccountRepository
import FileSystemPersistentStorage

public typealias AccountRepository = Repository<Account, JSONFileSystemPersistance<[Account]>>

extension AccountRepository {
    func loadPublisher() -> AnyPublisher<[Account], Never> {
        Just(self.readAccounts()).eraseToAnyPublisher()
    }

    func deletePublisher(accountID: UUID) -> AnyPublisher<Void, Error> {
        Future { completion in
            completion(Result { try self.delete(itemID: accountID) })
        }
        .eraseToAnyPublisher()
    }

    func savePublisher(account: Account) -> AnyPublisher<Void, Error> {
        Future { completion in
            completion(Result { try self.add(item: account) })
        }
        .eraseToAnyPublisher()
    }

    func movePublisher(fromID: UUID, toID: UUID) -> AnyPublisher<Void, Error> {
        Future { completion in
            completion(Result { try self.move(from: fromID, after: toID) })
        }
        .eraseToAnyPublisher()
    }
}
