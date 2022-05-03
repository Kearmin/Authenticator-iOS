// swiftlint:disable all
//  AddAccountSaveServiceAnalyticsDecoratorTests.swift
//  Authenticator-iOSTests
//
//  Created by Kertész Jenő Ármin on 2022. 05. 03..
//

import XCTest
import AddAccountBusiness
@testable import Authenticator_iOS

class AddAccountSaveServiceAnalyticsDecoratorTests: XCTestCase {
    func test_SUTCanLogEvent() throws {
        let env = TestEnviroment()
        env.mock.results = [.success(())]
        try env.sut.save(account: dummy)
        let event = env.analitycs.loggedEvents[0]
        XCTAssertEqual(event.name, "AuthenticatorAccountCreated")
        XCTAssertEqual(event.parameters?["issuer"] as? String, "issuer")
        XCTAssertEqual(event.parameters?["digits"] as? String, "6")
        XCTAssertEqual(event.parameters?["algorithm"] as? String, "sha1")
        XCTAssertEqual(event.parameters?["period"] as? String, "30")
    }

    func test_decoratorRethrowsError() throws {
        let env = TestEnviroment()
        let someError = SomeError()
        env.mock.results = [.failure(someError)]
        XCTAssertThrowsError(try env.sut.save(account: dummy)) { error in
            XCTAssertEqual(error as? SomeError, someError)
        }
    }

    func test_decoratorLogsError() throws {
        let env = TestEnviroment()
        env.mock.results = [.failure(SomeError())]
        XCTAssertThrowsError(try env.sut.save(account: dummy))
        XCTAssertEqual(env.analitycs.loggedEvents[0].name, "FailedToSaveAccount")
        XCTAssertNil(env.analitycs.loggedEvents[0].parameters)
    }

    class TestEnviroment {
        let sut: AddAccountSaveServiceAnalyticsDecorator
        let analitycs: AuthenticatorAnalitycsMock
        let mock: AddAccountSaveServiceMock

        init() {
            analitycs = AuthenticatorAnalitycsMock()
            mock = AddAccountSaveServiceMock()
            sut = AddAccountSaveServiceAnalyticsDecorator(mock, analitycs: analitycs)
        }
    }

    class AddAccountSaveServiceMock: AddAccountSaveService {
        var results: [Result<Void, Error>] = []

        func save(account: CreatAccountModel) throws {
            try results.removeFirst().get()
        }
    }

    private var dummy: CreatAccountModel {
        .init(issuer: "issuer", secret: "secret", username: "username", digits: "6", period: "30", algorithm: "sha1")
    }
}
