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
        env.mock.results = [
            .failure(AddAccountUseCaseErrors.notSupportedOTPMethod(method: "hotp")),
            .failure(AddAccountUseCaseErrors.notSupportedPeriod(period: "10")),
            .failure(AddAccountUseCaseErrors.notSupportedDigitCount(digit: "1")),
        ]

        validateFirstResult(env: env, expectedName: "FailedToSaveAccount_NotSupportedOTP", expectedParams: ["method": "hotp"])
        validateFirstResult(env: env, expectedName: "FailedToSaveAccount_NotSupportedPeriod", expectedParams: ["period": "10"])
        validateFirstResult(env: env, expectedName: "FailedToSaveAccount_NotSupportedDigit", expectedParams: ["digit": "1"])
    }

    private func validateFirstResult(env: TestEnviroment, expectedName name: String, expectedParams params: [String: String]) {
        try? env.sut.save(account: dummy)
        if let result = env.analitycs.loggedEvents.first {
            XCTAssertEqual(result.name, name)
            XCTAssertEqual(result.parameters as? [String : String], params)
            env.analitycs.loggedEvents.removeFirst()
        } else {
            XCTFail("Expected Result")
        }
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
