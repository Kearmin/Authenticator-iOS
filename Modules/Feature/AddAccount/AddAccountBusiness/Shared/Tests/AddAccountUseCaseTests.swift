//
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
    }

    func test_UseCaseCanParseShor2DataFromString() throws {
        let spy = AddAccountServiceSpy()
        let sut = makeSUT(spy: spy)
        try sut.createAccount(urlString: short2)
        let result = try XCTUnwrap(spy.savedAccounts.first)
        XCTAssertEqual(result.issuer, "linkedin")
        XCTAssertEqual(result.secret, "secret")
        XCTAssertEqual(result.username, "jake.doe@email.com")
    }

    func test_useCaseFailsIfOTPMethodIsHOTP() {
        XCTFail("Fail")
        let sut = makeSUT()
        XCTAssertThrowsError(try sut.createAccount(urlString: short.replacingOccurrences(of: "totp", with: "hotp")))
    }

    func test_useCaseFailsIfAlgorithIsNotSHA1() {
        let sut = makeSUT()
        XCTAssertThrowsError(try sut.createAccount(urlString: short + "&algorithm=SHA256"))
    }

    func test_usecaseFailsIfDigitsIsNot6() {
        let sut = makeSUT()
        XCTAssertThrowsError(try sut.createAccount(urlString: short + "&digits=8"))
    }

    func test_usecaseFailsIfPeriodIsNot30() {
        let sut = makeSUT()
        XCTAssertThrowsError(try sut.createAccount(urlString: short + "&period=60"))
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

    func save(account: CreatAccountModel) throws {
        savedAccounts.append(account)
    }
}
