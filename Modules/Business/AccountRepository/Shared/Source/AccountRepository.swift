//
//  AccountRepository.swift
//  Authenticator-iOS
//
//  Created by Kertész Jenő Ármin on 2022. 04. 24..
//

import Foundation

public protocol AccountRepositoryProvider {
    func save(accounts: [Account]) throws
    func readAccounts() throws -> [Account]
}

public enum AccountRepositoryError: Error {
    case accountAlreadyExists
}

public final class AccountRepository {
    private var provider: AccountRepositoryProvider
    private let queue: DispatchQueue
    private var inMemory: [Account]?

    public init(provider: AccountRepositoryProvider, queue: DispatchQueue) {
        self.provider = provider
        self.queue = queue
        inMemory = try? provider.readAccounts()
    }

    public func add(account: Account) throws {
        try queue.sync {
            guard !containsAccount(with: account.id) else {
                throw AccountRepositoryError.accountAlreadyExists
            }
            var mutableInMemory = inMemory ?? []
            mutableInMemory.append(account)
            try provider.save(accounts: mutableInMemory)
            inMemory = mutableInMemory
        }
    }

    public func readAccounts() -> [Account] {
        queue.sync {
            return inMemory ?? []
        }
    }

    public func delete(accountID: UUID) throws {
        try queue.sync {
            guard var mutableInMemory = inMemory else { return }
            mutableInMemory.removeAll { inMemoryAccount in
                inMemoryAccount.id == accountID
            }
            try provider.save(accounts: mutableInMemory)
            inMemory = mutableInMemory
        }
    }
}

private extension AccountRepository {
    func containsAccount(with id: UUID) -> Bool {
        guard let inMemory = inMemory else { return false }
        return inMemory.contains { $0.id == id }
    }
}
