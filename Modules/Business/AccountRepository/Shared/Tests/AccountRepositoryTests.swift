//
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
        let _ = makeSUT(mock: mock)
        XCTAssertEqual(mock.readAccountResults.count, 0)
    }

    func test_RepositoryCanSaveOneAccount() {
        let id = UUID()
        let account = account(id: id)
        let mock = AccountRepositoryMock()
        let sut = makeSUT(mock: mock)
        XCTAssertNoThrow(try sut.add(account: account))
        XCTAssertEqual(mock.savedAccounts.first, account)
    }

    func test_RepositoryCanSaveMultipleDiffenrentAccounts() {
        let id = UUID()
        let id2 = UUID()
        let account = self.account(id: id)
        let account2 = self.account(id: id2)
        let mock = AccountRepositoryMock()
        let sut = makeSUT(mock: mock)
        XCTAssertNoThrow(try sut.add(account: account))
        XCTAssertNoThrow(try sut.add(account: account2))
        XCTAssertEqual(mock.savedAccounts, [account, account2])
    }

    func test_RepositoryThrowsErrorOnAccountWithSameID() {
        let account = self.account()
        let mock = AccountRepositoryMock()
        mock.readAccountResults = [.success([account])]
        let sut = makeSUT(mock: mock)
        do {
            try sut.add(account: account)
            XCTFail("This should throw an error")
        } catch {
            XCTAssertEqual(AccountRepositoryError.accountAlreadyExists, error as? AccountRepositoryError)
        }
    }

    func test_RepositoryAddIsThreadSafe() {
        let mock = AccountRepositoryMock()
        let sut = makeSUT(mock: mock)
        let dispatchGroup = DispatchGroup()
        let exp = expectation(description: "add.multi.thread")
        let ids = (0..<100).map { _ in UUID() }
        for id in ids {
            dispatchGroup.enter()
            DispatchQueue.global().async {
                try! sut.add(account: self.account(id: id))
                dispatchGroup.leave()
            }
        }

        dispatchGroup.notify(queue: .main) {
            exp.fulfill()
        }

        wait(for: [exp], timeout: 0.1)
        for id in ids {
            // We can't guarantee that Dispatchqueue.global().async calls are in order
            // but we should guarantee that all of them are completed
            // and that it doesn't crash
            let savedIDs = mock.savedAccounts.map(\.id)
            XCTAssertTrue(savedIDs.contains(id))
        }
    }

    func test_RepositoryCanDeleteAccount() {
        let account = account()
        let mock = AccountRepositoryMock()
        mock.readAccountResults = [.success([account])]
        let sut = makeSUT(mock: mock)
        XCTAssertNoThrow(try sut.delete(accountID: account.id))
        XCTAssertEqual(mock.savedAccountCount, 0)
    }

    func test_addThrowsIfProviderFails() {
        let mock = AccountRepositoryMock()
        let sut = makeSUT(mock: mock)
        mock.shouldSaveThrowError = true
        XCTAssertThrowsError(try sut.add(account: account()))
    }

    func test_deleteThrowsIfProviderFails() {
        let mock = AccountRepositoryMock()
        let sut = makeSUT(mock: mock)
        mock.shouldSaveThrowError = true
        XCTAssertThrowsError(try sut.delete(accountID: account().id))
    }

    func makeSUT(mock: AccountRepositoryMock = .init()) -> AccountRepository {
        .init(provider: mock, queue: DispatchQueue(label: "test"))
    }

    private func account(id: UUID = UUID(), issuer: String = "issuer") -> Account {
        .init(id: id,
              issuer: issuer,
              secret: "secret",
              username: "username")
    }
}

class AccountRepositoryMock: AccountRepositoryProvider {
    var savedAccounts: [Account] = []
    var readAccountResults: [Result<[Account], Error>] = [.success([])]
    var shouldSaveThrowError = false
    var savedAccountCount: Int {
        savedAccounts.count
    }
    struct SomeError: Error { }

    func save(accounts: [Account]) throws {
        if shouldSaveThrowError { throw SomeError() }
        savedAccounts = accounts
    }

    func readAccounts() throws -> [Account] {
        try readAccountResults.removeFirst().get()
    }
}
