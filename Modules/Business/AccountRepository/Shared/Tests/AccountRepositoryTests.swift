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
        let id = UUID()
        let account = account(id: id)
        let mock = AccountRepositoryMock()
        let sut = makeSUT(mock: mock)
        XCTAssertNoThrow(try sut.add(item: account))
        XCTAssertEqual(mock.savedAccounts.first, account)
    }

    func test_RepositoryCanSaveMultipleDiffenrentAccounts() {
        let id = UUID()
        let id2 = UUID()
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

    func makeSUT(mock: AccountRepositoryMock = .init()) -> Repository<Account, AccountRepositoryMock> {
        .init(provider: mock)
    }

    private func account(id: UUID = UUID(), issuer: String = "issuer") -> Account {
        .init(id: id,
              issuer: issuer,
              secret: "secret",
              username: "username")
    }
}

struct Account: Identifiable, Equatable {
    let id: UUID
    let issuer: String
    let secret: String
    let username: String
}

class AccountRepositoryMock: RepositoryProvider {
    var savedAccounts: [Account] = []
    var readAccountResults: [Result<[Account], Error>] = [.success([])]
    var shouldSaveThrowError = false
    var savedAccountCount: Int {
        savedAccounts.count
    }
    var readAccountCallCount = 0
    struct SomeError: Error { }

    func save(items: [Account]) throws {
        if shouldSaveThrowError { throw SomeError() }
        savedAccounts = items
    }

    func readItems() throws -> [Account] {
        readAccountCallCount += 1
        return try readAccountResults.removeFirst().get()
    }
}
