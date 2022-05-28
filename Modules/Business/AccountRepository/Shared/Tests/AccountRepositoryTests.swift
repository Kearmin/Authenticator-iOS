// swiftlint:disable all
//  AccountRepositoryTests.swift
//  AccountRepository
//
//  Created by Kertész Jenő Ármin on 2022. 04. 24..
//

import XCTest
import AccountRepository
import AVFoundation

class AccountRepositoryTests: XCTestCase {
    func test_RepositoryReadsAccountOnInit() {
        let account = self.account()
        let mock = AccountRepositoryMock()
        mock.readAccountResults = [.success([account])]
        _ = makeSUT(mock: mock)
        XCTAssertEqual(mock.readAccountResults.count, 0)
    }

    func test_RepositoryCanSaveOneAccount() {
        let id = 0
        let account = account(id: id)
        let mock = AccountRepositoryMock()
        let sut = makeSUT(mock: mock)
        XCTAssertNoThrow(try sut.add(item: account))
        XCTAssertEqual(mock.savedAccounts.first, account)
    }

    func test_RepositoryCanSaveMultipleDiffenrentAccounts() {
        let id = 0
        let id2 = 1
        let account = self.account(id: id)
        let account2 = self.account(id: id2)
        let mock = AccountRepositoryMock()
        let sut = makeSUT(mock: mock)
        XCTAssertNoThrow(try sut.add(item: account))
        XCTAssertNoThrow(try sut.add(item: account2))
        XCTAssertEqual(mock.savedAccounts, [account, account2])
    }

    func test_RepositoryThrowsErrorOnAccountWithSameID() {
        let account = self.account()
        let mock = AccountRepositoryMock()
        mock.readAccountResults = [.success([account])]
        let sut = makeSUT(mock: mock)
        do {
            try sut.add(item: account)
            XCTFail("This should throw an error")
        } catch {
            XCTAssertEqual(RepositoryError.accountAlreadyExists, error as? RepositoryError)
        }
    }

    func test_RepositoryCanDeleteAccount() {
        let account = account()
        let mock = AccountRepositoryMock()
        mock.readAccountResults = [.success([account])]
        let sut = makeSUT(mock: mock)
        XCTAssertNoThrow(try sut.delete(itemID: account.id))
        XCTAssertEqual(mock.savedAccountCount, 0)
    }

    func test_addThrowsIfProviderFails() {
        let mock = AccountRepositoryMock()
        let sut = makeSUT(mock: mock)
        mock.shouldSaveThrowError = true
        XCTAssertThrowsError(try sut.add(item: account()))
    }

    func test_deleteThrowsIfProviderFails() {
        let mock = AccountRepositoryMock()
        let sut = makeSUT(mock: mock)
        mock.shouldSaveThrowError = true
        XCTAssertThrowsError(try sut.delete(itemID: account().id))
    }

    func test_readingIfNotChangedWillReadOnlyCachedValues() {
        let mock = AccountRepositoryMock()
        let sut = makeSUT(mock: mock)
        _ = sut.readAccounts()
        _ = sut.readAccounts()
        _ = sut.readAccounts()
        XCTAssertEqual(mock.readAccountCallCount, 1)
    }

    func test_repositoryAddsItem_IfUpdateIsCalledButDoesNotExists() {
        let mock = AccountRepositoryMock()
        let sut = makeSUT(mock: mock)
        let newItem = MockAccount(id: 0)
        XCTAssertNoThrow( try sut.update(item: newItem))
        XCTAssertEqual(mock.savedAccountCount, 1)
        XCTAssertEqual(mock.savedAccounts.first, newItem)
    }

    func test_repositoryUpdatesItem_ifUpdateIsCalledAndItemExists() {
        let id = 0
        let originalItem = MockAccount(id: id)
        let updatedItem = MockAccount(id: id)
        let mock = AccountRepositoryMock()
        mock.readAccountResults = [.success([originalItem])]
        let sut = makeSUT(mock: mock)
        XCTAssertNoThrow(try sut.update(item: updatedItem))
        XCTAssertEqual(mock.savedAccountCount, 1)
        XCTAssertEqual(mock.savedAccounts.first, updatedItem)
    }

    func test_repositoryCanSwap() {
        let mock = AccountRepositoryMock()
        let id1 = 0
        let id2 = 1
        let id3 = 2
        mock.readAccountResults = [.success([
            .init(id: id1),
            .init(id: id2),
            .init(id: id3)
        ])]
        let sut = makeSUT(mock: mock)
        mock.savedAccounts = sut.readAccounts()
        XCTAssertEqual(mock.savedAccounts[0].id, id1)
        XCTAssertEqual(mock.savedAccounts[1].id, id2)
        XCTAssertEqual(mock.savedAccounts[2].id, id3)
        XCTAssertNoThrow(try sut.swap(from: id1, to: id2))
        XCTAssertEqual(mock.savedAccounts[0].id, id2)
        XCTAssertEqual(mock.savedAccounts[1].id, id1)
        XCTAssertEqual(mock.savedAccounts[2].id, id3)
        XCTAssertNoThrow(try sut.swap(from: id1, to: id3))
        XCTAssertEqual(mock.savedAccounts[0].id, id2)
        XCTAssertEqual(mock.savedAccounts[1].id, id3)
        XCTAssertEqual(mock.savedAccounts[2].id, id1)
    }

    func test_repositoryDoestnSwapIfDoesntContainItem() {
        let mock = AccountRepositoryMock()
        mock.readAccountResults = [.success([])]
        let sut = makeSUT(mock: mock)
        XCTAssertThrowsError(try sut.swap(from: 10, to: 11))
    }

    func test_repositoryDoesntSwapInPlace() {
        let mock = AccountRepositoryMock()
        let id = 0
        mock.readAccountResults = [.success([
            .init(id: id)
        ])]
        let sut = makeSUT(mock: mock)
        XCTAssertNoThrow(try sut.swap(from: id, to: id))
        XCTAssertEqual(mock.savedAccountCount, 0)
    }

    func test_canMoveItemsForward() {
        let mock = AccountRepositoryMock()
        let id1 = 0
        let id2 = 1
        let id3 = 2
        mock.readAccountResults = [.success([
            .init(id: id1),
            .init(id: id2),
            .init(id: id3)
        ])]
        let sut = makeSUT(mock: mock)
        XCTAssertNoThrow(try sut.move(from: id1, after: id2))
        XCTAssertEqual(mock.savedAccounts[0].id, id2)
        XCTAssertEqual(mock.savedAccounts[1].id, id1)
        XCTAssertEqual(mock.savedAccounts[2].id, id3)
        XCTAssertNoThrow(try sut.move(from: id2, after: id3))
        XCTAssertEqual(mock.savedAccounts[0].id, id1)
        XCTAssertEqual(mock.savedAccounts[1].id, id3)
        XCTAssertEqual(mock.savedAccounts[2].id, id2)
    }

    func test_canMoveItemsBackward() {
        let mock = AccountRepositoryMock()
        let id1 = 0
        let id2 = 1
        let id3 = 2
        mock.readAccountResults = [.success([
            .init(id: id1),
            .init(id: id2),
            .init(id: id3)
        ])]
        let sut = makeSUT(mock: mock)
        XCTAssertNoThrow(try sut.move(from: id3, after: id1))
        XCTAssertEqual(mock.savedAccounts[0].id, id3)
        XCTAssertEqual(mock.savedAccounts[1].id, id1)
        XCTAssertEqual(mock.savedAccounts[2].id, id2)
        XCTAssertNoThrow(try sut.move(from: id1, after: id3))
        XCTAssertEqual(mock.savedAccounts[0].id, id1)
        XCTAssertEqual(mock.savedAccounts[1].id, id3)
        XCTAssertEqual(mock.savedAccounts[2].id, id2)
        XCTAssertNoThrow(try sut.move(from: id2, after: id3))
        XCTAssertEqual(mock.savedAccounts[0].id, id1)
        XCTAssertEqual(mock.savedAccounts[1].id, id2)
        XCTAssertEqual(mock.savedAccounts[2].id, id3)
    }

    func makeSUT(mock: AccountRepositoryMock = .init()) -> Repository<MockAccount, AccountRepositoryMock> {
        .init(provider: mock)
    }

    private func account(id: Int = (0..<Int.max).randomElement()!) -> MockAccount {
        .init(id: id)
    }
}

struct MockAccount: Identifiable, Equatable {
    let id: Int
}

class AccountRepositoryMock: RepositoryProvider {
    var savedAccounts: [MockAccount] = []
    var readAccountResults: [Result<[MockAccount], Error>] = [.success([])]
    var shouldSaveThrowError = false
    var savedAccountCount: Int {
        savedAccounts.count
    }
    var readAccountCallCount = 0
    struct SomeError: Error { }

    func save(items: [MockAccount]) throws {
        if shouldSaveThrowError { throw SomeError() }
        savedAccounts = items
    }

    func readItems() throws -> [MockAccount] {
        readAccountCallCount += 1
        return try readAccountResults.removeFirst().get()
    }
}
