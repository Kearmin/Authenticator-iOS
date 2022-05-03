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

        try? env.sut.save(account: dummy)
        if let result = env.analitycs.loggedEvents.first {
            XCTAssertEqual(result.name, "FailedToSaveAccount_NotSupportedOTP")
            XCTAssertEqual(result.parameters as? [String : String], ["method": "hotp"])
            env.analitycs.loggedEvents.removeFirst()
        }
        try? env.sut.save(account: dummy)
        if let result = env.analitycs.loggedEvents.first {
            XCTAssertEqual(result.name, "FailedToSaveAccount_NotSupportedPeriod")
            XCTAssertEqual(result.parameters as? [String : String], ["period": "10"])
            env.analitycs.loggedEvents.removeFirst()
        }
        try? env.sut.save(account: dummy)
        if let result = env.analitycs.loggedEvents.first {
            XCTAssertEqual(result.name, "FailedToSaveAccount_NotSupportedDigit")
            XCTAssertEqual(result.parameters as? [String : String], ["digit": "1"])
            env.analitycs.loggedEvents.removeFirst()
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
