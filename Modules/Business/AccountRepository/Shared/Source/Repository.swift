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

public final class Repository<Item: Identifiable, Provider: RepositoryProvider> {
    public typealias Mapper = (Item) -> Provider.Item
    public typealias ReverseMapper = (Provider.Item) -> Item
    private var mapper: Mapper
    private var reverseMapper: ReverseMapper

    private var provider: Provider
    private var inMemory: [Item]?

    public init(provider: Provider) where Provider.Item == Item {
        self.provider = provider
        mapper = { $0 }
        reverseMapper = { $0 }
        inMemory = try? provider.readItems()
    }

    public init(provider: Provider, mapper: @escaping Mapper, reverseMapper: @escaping ReverseMapper) {
        self.provider = provider
        self.mapper = mapper
        self.reverseMapper = reverseMapper
        inMemory = try? provider.readItems().map(reverseMapper)
    }

    public func add(item: Item) throws {
        guard !containsAccount(with: item.id) else {
            throw RepositoryError.accountAlreadyExists
        }
        var mutableInMemory = inMemory ?? []
        mutableInMemory.append(item)
        try provider.save(items: mutableInMemory.map(mapper))
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
        try provider.save(items: mutableInMemory.map(mapper))
        inMemory = mutableInMemory
    }
}

private extension Repository {
    func containsAccount(with id: Item.ID) -> Bool {
        guard let inMemory = inMemory else { return false }
        return inMemory.contains { $0.id == id }
    }
}
