// swiftlint:disable all
//  AuthenticatorListIntegrationTests.swift
//  Authenticator-iOSIntegrationTests
//
//  Created by Kertész Jenő Ármin on 2022. 05. 24..
//

import XCTest
import Combine
import AuthenticatorListBusiness
@testable import Authenticator_iOS

class AuthenticatorListIntegrationTests: XCTestCase {
    func test_ListHastTitle() {
        let loader = ListLoaderStub()
        let viewController = ListComposer.list(dependencies: .init(
            totpProvider: TOTPProviderMock(),
            readAccounts: loader.readAccounts,
            delete: loader.delete,
            favourite: loader.favourite,
            update: loader.update,
            refreshPublisher: loader.refresh,
            clockPublisher: loader.clock)
        )
        XCTAssertEqual(viewController.0.title, "Authenticator")
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
