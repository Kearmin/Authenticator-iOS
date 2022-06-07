// swiftlint:disable all
//  AuthenticatorListIntegrationTests.swift
//  Authenticator-iOSIntegrationTests
//
//  Created by Kertész Jenő Ármin on 2022. 05. 24..
//

import XCTest
import Combine
import AuthenticatorListBusiness
import AuthenticatorListView
@testable import Authenticator_iOS

class AuthenticatorListIntegrationTests: XCTestCase {
    func test_ListHastTitle() {
        let env = makeSUT()
        XCTAssertEqual(env.sutViewController.title, "Authenticator")
    }

    func test_ListCanRenderAccounts() {
    }

    func makeSUT() -> TestEnvironment {
        let env = TestEnvironment()
        trackForMemoryLeaks(env.sutViewController)
        trackForMemoryLeaks(env.sutViewModel)
        trackForMemoryLeaks(env.loader)
        return env
    }

    class TestEnvironment {
        let loader: ListLoaderStub
        let sutView: AuthenticatorListView
        let sutViewController: AuthenticatorListViewController
        let sutViewModel: AuthenticatorListViewModel

        init(loader: ListLoaderStub = .init()) {
            self.loader = loader
            self.sutViewController = ListComposer.list(dependencies: .init(
                totpProvider: TOTPProviderMock(),
                readAccounts: loader.readAccounts,
                delete: loader.delete,
                favourite: loader.favourite,
                update: loader.update,
                refreshPublisher: loader.refresh,
                clockPublisher: loader.clock)
            ).0
            self.sutView = sutViewController.rootView
            self.sutViewModel = sutViewController.viewModel
        }
    }
}

extension AuthenticatorListIntegrationTests {
}

extension XCTestCase {
    func trackForMemoryLeaks(_ instance: AnyObject, file: StaticString = #filePath, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Instance should have been deallocated. Potential memory leak.", file: file, line: line)
        }
    }
}

class ListLoaderStub {
    var readAccounts: () -> AnyPublisher<[AuthenticatorAccountModel], Never> = { Empty().eraseToAnyPublisher() }
    var delete: (UUID) -> AnyPublisher<Void, Error> = { _ in Empty().eraseToAnyPublisher() }
    var favourite: (UUID) -> AnyPublisher<Void, Error> = { _ in Empty().eraseToAnyPublisher() }
    var refresh: AnyPublisher<Void, Never> = Empty().eraseToAnyPublisher()
    var update: (AuthenticatorAccountModel) -> AnyPublisher<Void, Error> = { _ in Empty().eraseToAnyPublisher() }
    var clock: AnyPublisher<Date, Never> = Empty().eraseToAnyPublisher()
}

class TOTPProviderMock: AuthenticatorTOTPProvider {
    func totp(secret: String, date: Date, digits: Int, timeInterval: Int, algorithm: AuthenticatorTOTPAlgorithm) -> String? {
        ""
    }

    func totpPublisher(secret: String, date: Date, digits: Int, timeInterval: Int, algorithm: AuthenticatorTOTPAlgorithm) -> AnyPublisher<String?, Never> {
        Empty().eraseToAnyPublisher()
    }
}
