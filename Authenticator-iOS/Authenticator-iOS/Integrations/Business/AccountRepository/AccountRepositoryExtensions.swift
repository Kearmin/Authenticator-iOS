//
//  AccountRepositoryExtensions.swift
//  Authenticator-iOS
//
//  Created by Kertész Jenő Ármin on 2022. 05. 14..
//

import Combine
import AccountRepository
import FileSystemPersistentStorage
import AuthenticatorListBusiness

public typealias AccountJSONFileSystemPersistance = JSONFileSystemPersistance<[AuthenticatorAccountModel]>
public typealias AccountRepository = Repository<AuthenticatorAccountModel, AccountJSONFileSystemPersistance>

extension AccountRepository {
    func loadPublisher() -> AnyPublisher<[AuthenticatorAccountModel], Never> {
        Just(self.readAccounts()).eraseToAnyPublisher()
    }

    func deletePublisher(accountID: UUID) -> AnyPublisher<Void, Error> {
        Future { completion in
            completion(Result { try self.delete(itemID: accountID) })
        }
        .eraseToAnyPublisher()
    }

    func savePublisher(account: AuthenticatorAccountModel) -> AnyPublisher<Void, Error> {
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

    func favourite(_ account: UUID) -> AnyPublisher<Void, Error> {
        Future { completion in
            do {
                var account = try self.item(for: account)
                account.isFavourite.toggle()
                try self.update(item: account)
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }

    func update(_ account: AuthenticatorAccountModel) -> AnyPublisher<Void, Error> {
        Future { completion in
            completion(Result { try self.update(item: account) })
        }
        .eraseToAnyPublisher()
    }
}
