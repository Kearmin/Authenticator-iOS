// swiftlint:disable all
//  AuthenticatorListIntegrationTests.swift
//  Authenticator-iOSIntegrationTests
//
//  Created by Kertész Jenő Ármin on 2022. 05. 24..
//

import XCTest
import Combine
@testable import Authenticator_iOS

class AuthenticatorListIntegrationTests: XCTestCase {
    func test_ListHastTitle() {
        let loader = ListLoaderStub()
        let viewController = ListComposer.list(dependencies: .init(
            totpProvider: TOTPProviderMock(),
            readAccounts: loader.readAccounts,
            delete: loader.delete,
            moveAccounts: loader.swap,
            appEventPublisher: loader.appEventPublisher)
        )
        XCTAssertEqual(viewController.0.title, "Authenticator")
    }
}

class ListLoaderStub {

    var appEventSubject = PassthroughSubject<AppEvent, Never>()

    var readAccounts: () -> AnyPublisher<[Account], Never> = { Empty().eraseToAnyPublisher() }
    var delete: (UUID) -> AnyPublisher<Void, Error> = { _ in Empty().eraseToAnyPublisher() }
    var appEventPublisher: AnyPublisher<AppEvent, Never> {
        appEventSubject.eraseToAnyPublisher()
    }
    var swap: (UUID, UUID) -> AnyPublisher<Void, Error> = { _, _ in
        Empty().eraseToAnyPublisher()
    }
}

class TOTPProviderMock: TOTPProvider {
    func totp(secret: String, date: Date, digits: Int, timeInterval: Int, algorithm: AuthenticatorTOTPAlgorithm) -> String? {
        ""
    }

    func totpPublisher(secret: String, date: Date, digits: Int, timeInterval: Int, algorithm: AuthenticatorTOTPAlgorithm) -> AnyPublisher<String?, Never> {
        Empty().eraseToAnyPublisher()
    }
}
