// swiftlint:disable all
//  AuthenticatorListTests.swift
//  AuthenticatoriOSTests
//
//  Created by Kertész Jenő Ármin on 2022. 04. 21..
//

import Combine
import XCTest
import AuthenticatorListBusiness

class AuthenticatorListTests: XCTestCase {

    weak var weakSUT: AuthenticatorListPresenter?

    override func tearDown() {
        super.tearDown()
        XCTAssertNil(weakSUT)
    }

    // 2022. April 21., Thursday 22:25:00 GMT
    var april_21_2022_222500_GMT: TimeInterval = 1650579900
    // 2022. April 21., Thursday 22:25:05 GMT
    var april_21_2022_222505_GMT: TimeInterval = 1650579905
    // 2022. April 21., Thursday 22:25:23 GMT
    var april_21_2022_222523_GMT: TimeInterval = 1650579923

    func test_PresenterOutputs30SecondsIfMinuteIs00AndIntervalIs30Sec() {
        testTimeIntervalLeftIfMinuteIs00(
            epochTime: april_21_2022_222500_GMT,
            cycleLength: 30,
            expectedResult: "30")
    }

    func test_PresenterOutputs60SecondsIfMinuteIs00AndIntervalIs60Sec() {
        testTimeIntervalLeftIfMinuteIs00(
            epochTime: april_21_2022_222500_GMT,
            cycleLength: 60,
            expectedResult: "60")
    }

    func test_PresenterOutputs25SecondsIfMinuteIs05AndIntervalIs30Sec() {
        testTimeIntervalLeftIfMinuteIs00(
            epochTime: april_21_2022_222505_GMT,
            cycleLength: 30,
            expectedResult: "25")
    }

    func test_PresenterOutputs7SecondsIfMinuteIs23AndIntervalIs30Sec() {
        testTimeIntervalLeftIfMinuteIs00(
            epochTime: april_21_2022_222523_GMT,
            cycleLength: 30,
            expectedResult: "7")
    }

    func test_PresenterCanReturnMultipleCorrectValuesInSuccessionIfIntervalIs30() {
        let mock = AuthenticatorListPresenterServiceMock()
        mock.cycleLength = 30
        let sut = makeSUT(mock: mock)
        let spy = AuthenticatorListPresenterSpy()
        sut.output = spy
        testMultipleInputsInSuccession(
            mock: mock,
            spy: spy,
            inputs: [
                (epoch: april_21_2022_222500_GMT, expected: "30"),
                (epoch: april_21_2022_222505_GMT, expected: "25"),
                (epoch: april_21_2022_222523_GMT, expected: "7"),
            ])
    }

    func test_PresenterCanReturnMultipleCorrectValuesInSuccessionIfIntervalIs60() {
        let mock = AuthenticatorListPresenterServiceMock()
        mock.cycleLength = 60
        let sut = makeSUT(mock: mock)
        let spy = AuthenticatorListPresenterSpy()
        sut.output = spy
        testMultipleInputsInSuccession(
            mock: mock,
            spy: spy,
            inputs: [
                (epoch: april_21_2022_222500_GMT, expected: "60"),
                (epoch: april_21_2022_222505_GMT, expected: "55"),
                (epoch: april_21_2022_222523_GMT, expected: "37"),
            ])
    }

    func test_PresenterCallsLoadAccountsOnLoad() {
        let mock = AuthenticatorListPresenterServiceMock()
        let sut = makeSUT(mock: mock)
        sut.load()
        XCTAssertEqual(mock.loadAccountCallCount, 1)
    }

    func test_CanReceiveEmptySuccessResult() {
        let spy = AuthenticatorListPresenterSpy()
        let sut = makeSUT()
        sut.output = spy
        sut.receive(result: .success([]))
        XCTAssertEqual(spy.receivedRows.count, 1)
        XCTAssertEqual(spy.receivedRows.first, [])
    }

    func test_CanReceiveDummySuccessResult() {
        let mock = AuthenticatorListPresenterServiceMock()
        let spy = AuthenticatorListPresenterSpy()
        let sut = makeSUT(mock: mock)
        mock.getTOTPResult = "totp"
        sut.output = spy
        let id = UUID()
        sut.receive(result: .success([
            .init(id: id, issuer: "issuer", username: "username", secret: "secret")
        ]))
        XCTAssertEqual(spy.receivedRows.count, 1)
        XCTAssertEqual(spy.receivedRows.first, [.init(id: id, issuer: "issuer", username: "username", TOTPCode: "totp")])
    }

    func test_PresenterReturnsLatestCorrectFirstValueOnSettingOutput() {
        let mock = AuthenticatorListPresenterServiceMock()
        mock.cycleLength = 30
        let sut = makeSUT(mock: mock)
        let spy = AuthenticatorListPresenterSpy()
        mock.receiveCurrentDate?(Date(timeIntervalSince1970: april_21_2022_222500_GMT))
        mock.receiveCurrentDate?(Date(timeIntervalSince1970: april_21_2022_222505_GMT))
        sut.output = spy
        XCTAssertEqual(spy.receivedCountDowns.count, 1)
        XCTAssertEqual(spy.receivedCountDowns.last, "25")
    }

    func test_PresenterOutputsNewRowContent_WhenCycleIsFinished() {
        let mock = AuthenticatorListPresenterServiceMock()
        mock.cycleLength = 30
        let spy = AuthenticatorListPresenterSpy()
        let sut = makeSUT(mock: mock)
        mock.getTOTPResult = "totp"
        sut.output = spy
        let id = UUID()
        sut.receive(result: .success([
            .init(id: id, issuer: "issuer", username: "username", secret: "secret")
        ]))
        XCTAssertEqual(spy.receivedRows.count, 1)
        XCTAssertEqual(spy.receivedRows.first, [.init(id: id, issuer: "issuer", username: "username", TOTPCode: "totp")])
        mock.receiveCurrentDate?(Date(timeIntervalSince1970: april_21_2022_222505_GMT))
        XCTAssertEqual(spy.receivedRows.count, 1)
        mock.getTOTPResult = "totp2"
        mock.receiveCurrentDate?(Date(timeIntervalSince1970: april_21_2022_222500_GMT))
        XCTAssertEqual(spy.receivedRows.count, 2)
        XCTAssertEqual(spy.receivedRows.last?[0].TOTPCode, "totp2")
    }

    func test_PresenterCallsDeleteService_OnDeleteCalles() {
        let id = UUID()
        let mock = AuthenticatorListPresenterServiceMock()
        let sut = makeSUT(mock: mock)
        sut.deleteAccount(id: id)
        XCTAssertEqual(mock.deleteCallIDCount, 1)
        XCTAssertEqual(mock.deleteCallIDS.last, id)
    }

    func test_PresenterDoesntOutputDeletedAccount_IfDeleteSucceeds() {
        let id = UUID()
        let account = AuthenticatorAccountModel(id: id, issuer: "issuer", username: "username", secret: "secret")
        let mock = AuthenticatorListPresenterServiceMock()
        let spy = AuthenticatorListPresenterSpy()
        mock.accountsResults = [.success([account])]
        let sut = makeSUT(mock: mock)
        sut.output = spy
        sut.receive(result: .success([account]))
        XCTAssertEqual(spy.receivedRows.count, 1)
        XCTAssertEqual(spy.receivedRows.last?[0].id, account.id)
        sut.deleteAccount(id: id)
        XCTAssertEqual(spy.receivedRows.count, 2)
        XCTAssertEqual(spy.receivedRows.last, [])
    }

    private func testTimeIntervalLeftIfMinuteIs00(epochTime: TimeInterval, cycleLength: Int, expectedResult: String) {
        let mock = AuthenticatorListPresenterServiceMock()
        mock.cycleLength = cycleLength
        let sut = makeSUT(mock: mock)
        let minuteStartDate = Date(timeIntervalSince1970: epochTime)
        let spy = AuthenticatorListPresenterSpy()
        sut.output = spy
        mock.receiveCurrentDate?(minuteStartDate)
        XCTAssertEqual(spy.receivedCountDowns.count, 1)
        XCTAssertEqual(spy.receivedCountDowns.first, expectedResult)
    }

    private func testMultipleInputsInSuccession(
        mock: AuthenticatorListPresenterServiceMock,
        spy: AuthenticatorListPresenterSpy,
        inputs: [(epoch: TimeInterval, expected: String)])
    {
        var iterations = 0
        for input in inputs {
            iterations += 1
            let date = Date(timeIntervalSince1970: input.epoch)
            mock.receiveCurrentDate?(date)
            XCTAssertEqual(spy.receivedCountDowns.count, iterations)
            XCTAssertEqual(spy.receivedCountDowns.last, input.expected)
        }
    }

    func makeSUT(mock: AuthenticatorListPresenterServiceMock = .init()) -> AuthenticatorListPresenter {
        let sut = AuthenticatorListPresenter(service: mock)
        weakSUT = sut
        return sut
    }
}

class AuthenticatorListPresenterSpy: AuthenticatorListPresenterDelegate {
    var receivedCountDowns: [String] = []
    var receivedRows: [[AuthenticatorListRowContent]] = []
    func receive(rows: [AuthenticatorListRowContent]) {
        receivedRows.append(rows)
    }
    func receive(countDown: String) {
        receivedCountDowns.append(countDown)
    }
}


class AuthenticatorListPresenterServiceMock: AuthenticatorListPresenterService {
    var loadAccountCallCount = 0
    var accountsResults: [Result<[AuthenticatorAccountModel], Error>] = []
    var getTOTPResult: String = ""
    var receiveCurrentDate: ((Date) -> Void)?
    var cycleLength: Int = 1
    var deleteCallIDS: [UUID] = []
    var deleteCallIDCount: Int {
        deleteCallIDS.count
    }

    func loadAccounts() {
        loadAccountCallCount += 1
    }

    func getAuthenticatorAccounts(completion: @escaping (Result<[AuthenticatorAccountModel], Error>) -> Void) {
        completion(accountsResults.removeFirst())
    }

    func getTOTP(secret: String, timeInterval: Int, date: Date) -> String {
        getTOTPResult
    }

    func deleteAccount(id: UUID) {
        deleteCallIDS.append(id)
    }
}
