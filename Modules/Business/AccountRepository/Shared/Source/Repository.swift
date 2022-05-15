//
//  AccountRepository.swift
//  Authenticator-iOS
//
//  Created by Kertész Jenő Ármin on 2022. 04. 24..
//

import Foundation

public protocol RepositoryProvider {
    associatedtype Item

    func save(items: [Item]) throws
    func readItems() throws -> [Item]
}

public enum RepositoryError: Error {
    case accountAlreadyExists
}

public final class Repository<Item: Identifiable, Provider: RepositoryProvider> where Provider.Item == Item {
    private var provider: Provider
    private var inMemory: [Item]?

    public init(provider: Provider) {
        self.provider = provider
        inMemory = try? provider.readItems()
    }

    public func add(item: Item) throws {
        guard !containsAccount(with: item.id) else {
            throw RepositoryError.accountAlreadyExists
        }
        var mutableInMemory = inMemory ?? []
        mutableInMemory.append(item)
        try provider.save(items: mutableInMemory)
        inMemory = mutableInMemory
    }

    public func readAccounts() -> [Item] {
        return inMemory ?? []
    }

    public func delete(itemID: Item.ID) throws {
        guard var mutableInMemory = inMemory else { return }
        mutableInMemory.removeAll { inMemoryAccount in
            inMemoryAccount.id == itemID
        }
        try provider.save(items: mutableInMemory)
        inMemory = mutableInMemory
    }
}

private extension Repository {
    func containsAccount(with id: Item.ID) -> Bool {
        guard let inMemory = inMemory else { return false }
        return inMemory.contains { $0.id == id }
    }
}
