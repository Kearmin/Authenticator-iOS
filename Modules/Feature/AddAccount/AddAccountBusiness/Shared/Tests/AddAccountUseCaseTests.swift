// swiftlint:disable all
//  AddAccountUseCaseTests.swift
//  AddAccountBusiness
//
//  Created by Kertész Jenő Ármin on 2022. 04. 22..
//

import XCTest
import AddAccountBusiness

class AddAccountUseCaseTests: XCTestCase {
    var long = "otpauth://totp/ACME%20Co:john.doe@email.com?secret=HXDMVJECJJWSRB3HWIZR4IFUGFTMXBOZ&issuer=ACME%20Co&algorithm=SHA1&digits=6&period=30"

    var short = "otpauth://totp/john.doe@email.com?secret=HXDMVJECJJWSRB3HWIZR4IFUGFTMXBOZ&issuer=issuer"

    var short2 = "otpauth://totp/linkedin:jake.doe@email.com?secret=secret&issuer=linkedin"

    func test_UseCaseCanParseShortDataFromString() throws {
        let spy = AddAccountServiceSpy()
        let sut = makeSUT(spy: spy)
        try! sut.createAccount(urlString: short)
        let result = try XCTUnwrap(spy.savedAccounts.first)
        XCTAssertEqual(result.issuer, "issuer")
        XCTAssertEqual(result.secret, "HXDMVJECJJWSRB3HWIZR4IFUGFTMXBOZ")
        XCTAssertEqual(result.username, "john.doe@email.com")
        XCTAssertEqual(result.digits, "6")
        XCTAssertEqual(result.period, "30")
        XCTAssertEqual(result.algorithm, "sha1")
    }

    func test_UseCaseCanParseShor2DataFromString() throws {
        let spy = AddAccountServiceSpy()
        let sut = makeSUT(spy: spy)
        try sut.createAccount(urlString: short2)
        let result = try XCTUnwrap(spy.savedAccounts.first)
        XCTAssertEqual(result.issuer, "linkedin")
        XCTAssertEqual(result.secret, "secret")
        XCTAssertEqual(result.username, "jake.doe@email.com")
        XCTAssertEqual(result.digits, "6")
        XCTAssertEqual(result.period, "30")
        XCTAssertEqual(result.algorithm, "sha1")
    }

    func test_useCaseFailsIfUrlIsInvalid() {
        let sut = makeSUT()
        XCTAssertThrowsError(try sut.createAccount(urlString: "notAnURL")) { error in
            XCTAssertEqual(error as? AddAccountUseCaseErrors, .invalidURL(URL: "notAnURL"))
        }
    }

    func test_useCaseFailsIfIssuerIsMissing() {
        let sut = makeSUT()
        let issuerMissingUrl = short.replacingOccurrences(of: "issuer", with: "notissuer")
        XCTAssertThrowsError(try sut.createAccount(urlString: issuerMissingUrl)) { error in
            XCTAssertEqual(error as? AddAccountUseCaseErrors, .invalidURL(URL: issuerMissingUrl))
        }
    }

    func test_useCaseFailsIfSecretIsMissing() {
        let sut = makeSUT()
        let secretMissingUrl = short.replacingOccurrences(of: "secret", with: "notsecret")
        XCTAssertThrowsError(try sut.createAccount(urlString: secretMissingUrl)) { error in
            XCTAssertEqual(error as? AddAccountUseCaseErrors, .invalidURL(URL: secretMissingUrl))
        }
    }

    func test_useCaseFailsIfOTPMethodIsHOTP() {
        let sut = makeSUT()
        let url = short.replacingOccurrences(of: "totp", with: "hotp")
        XCTAssertThrowsError(try sut.createAccount(urlString: url)) { error in
            XCTAssertEqual(error as? AddAccountUseCaseErrors, .notSupportedOTPMethod(method: "hotp"))
        }
    }

    func test_useCaseFailsIfAlgorithIsNotSHA1() {
        let sut = makeSUT()
        XCTAssertThrowsError(try sut.createAccount(urlString: short + "&algorithm=SHA256")) { error in
            XCTAssertEqual(error as? AddAccountUseCaseErrors, .notSupportedAlgorithm(algorithm: "sha256"))
        }
    }

    func test_useCaseIsCaseInsensitiveForAlgorithm() {
        let sut = makeSUT()
        XCTAssertNoThrow(try sut.createAccount(urlString: short + "&algorithm=SHA1"))
    }

    func test_usecaseFailsIfDigitsIsNot6() {
        let sut = makeSUT()
        XCTAssertThrowsError(try sut.createAccount(urlString: short + "&digits=8")) { error in
            XCTAssertEqual(error as? AddAccountUseCaseErrors, .notSupportedDigitCount(digit: "8"))
        }
    }

    func test_usecaseFailsIfPeriodIsNot30() {
        let sut = makeSUT()
        XCTAssertThrowsError(try sut.createAccount(urlString: short + "&period=60")) { error in
            XCTAssertEqual(error as? AddAccountUseCaseErrors, .notSupportedPeriod(period: "60"))
        }
    }

    func makeSUT(spy: AddAccountServiceSpy = .init()) -> AddAccountUseCase {
        .init(saveService: spy)
    }

    private func validShortURL(issuer: String = "issuer", secret: String = "secret", username: String = "username") -> String {
        "otpauth://totp/\(username)?secret=\(secret)&issuer=\(issuer)"
    }
}

final class AddAccountServiceSpy: AddAccountSaveService {
    var savedAccounts: [CreatAccountModel] = []
    var savedCount: Int {
        savedAccounts.count
    }

    func save(account: CreatAccountModel) {
        savedAccounts.append(account)
    }
}
