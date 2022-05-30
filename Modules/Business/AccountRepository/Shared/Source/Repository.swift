//
//  AccountRepository.swift
//  Authenticator-iOS
//
//  Created by Kertész Jenő Ármin on 2022. 04. 24..
//

import Foundation
import Combine

public protocol RepositoryProvider {
    associatedtype Item

    func save(items: [Item]) throws
    func readItems() throws -> [Item]
}

public enum RepositoryError: Error {
    case accountAlreadyExists
    case accountNotFound
}

public final class Repository<Item: Identifiable, Provider: RepositoryProvider> {
    public typealias Mapper = (Item) -> Provider.Item
    public typealias ReverseMapper = (Provider.Item) -> Item
    private var mapper: Mapper
    private let didSaveSubject = PassthroughSubject<Void, Never>()

    private var provider: Provider
    private var inMemory: [Item]?

    public var didSavePublisher: AnyPublisher<Void, Never> {
        didSaveSubject.eraseToAnyPublisher()
    }

    public init(provider: Provider) where Provider.Item == Item {
        self.provider = provider
        mapper = { $0 }
        inMemory = try? provider.readItems()
    }

    public init(provider: Provider, mapper: @escaping Mapper, reverseMapper: @escaping ReverseMapper) {
        self.provider = provider
        self.mapper = mapper
        inMemory = try? provider.readItems().map(reverseMapper)
    }

    public func add(item: Item) throws {
        guard !containsItem(with: item.id) else {
            throw RepositoryError.accountAlreadyExists
        }
        var mutableInMemory = inMemory ?? []
        mutableInMemory.append(item)
        try save(mutableInMemory)
    }

    public func update(item: Item) throws {
        if var mutableInMemory = inMemory, let index = mutableInMemory.firstIndex(where: { $0.id == item.id }) {
            mutableInMemory[index] = item
            try save(mutableInMemory)
        } else {
            try add(item: item)
        }
    }

    public func readAccounts() -> [Item] {
        return inMemory ?? []
    }

    public func delete(itemID: Item.ID) throws {
        guard var mutableInMemory = inMemory else { return }
        mutableInMemory.removeAll { inMemoryAccount in
            inMemoryAccount.id == itemID
        }
        try save(mutableInMemory)
    }

    public func swap(from fromID: Item.ID, to toID: Item.ID) throws {
        guard
            var mutableMemory = inMemory,
            let fromIndex = mutableMemory.firstIndex(where: { $0.id == fromID }),
            let toIndex = mutableMemory.firstIndex(where: { $0.id == toID })
        else { throw RepositoryError.accountNotFound }
        guard fromIndex != toIndex else { return }
        mutableMemory.swapAt(fromIndex, toIndex)
        try save(mutableMemory)
    }

    public func move(from fromID: Item.ID, after toID: Item.ID) throws {
        guard
            var mutableMemory = inMemory,
            let fromIndex = mutableMemory.firstIndex(where: { $0.id == fromID }),
            let toIndex = mutableMemory.firstIndex(where: { $0.id == toID })
        else { throw RepositoryError.accountNotFound }
        guard fromIndex != toIndex else { return }
        if fromIndex < toIndex {
            let fromValue = mutableMemory[fromIndex]
            for index in (fromIndex..<toIndex) {
                mutableMemory[index] = mutableMemory[index + 1]
            }
            mutableMemory[toIndex] = fromValue
        } else {
            let fromValue = mutableMemory[fromIndex]
            for index in ((toIndex + 1)...fromIndex).reversed() {
                mutableMemory[index] = mutableMemory[index - 1]
            }
            mutableMemory[toIndex] = fromValue
        }
        try save(mutableMemory)
    }
}

private extension Repository {
    func save(_ items: [Item]) throws {
        try provider.save(items: items.map(mapper))
        inMemory = items
        didSaveSubject.send()
    }

    func containsItem(with id: Item.ID) -> Bool {
        guard let inMemory = inMemory else { return false }
        return inMemory.contains { $0.id == id }
    }
}
