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

    weak var weakSUT: AuthenticatorListBusiness?

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
        let sut = makeSUT(mock: mock)
        let spy = AuthenticatorListPresenterSpy()
        sut.output = spy
        testMultipleInputsInSuccession(
            sut: sut,
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
        let sut = makeSUT(mock: mock, cycleLength: 60)
        let spy = AuthenticatorListPresenterSpy()
        sut.output = spy
        testMultipleInputsInSuccession(
            sut: sut,
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
        XCTAssertEqual(spy.receivedSections.count, 1)
        XCTAssertEqual(spy.receivedSections.first?[0].rowContent, [])
    }

    func test_CanReceiveDummySuccessResult() {
        let mock = AuthenticatorListPresenterServiceMock()
        let spy = AuthenticatorListPresenterSpy()
        let sut = makeSUT(mock: mock)
        mock.getTOTPResult = "totp"
        sut.output = spy
        let id = UUID()
        sut.receive(result: .success([
            .init(id: id, issuer: "issuer", username: "username", secret: "secret", isFavourite: false)
        ]))
        XCTAssertEqual(spy.receivedSections.count, 1)
        XCTAssertEqual(spy.receivedSections.first?[0].rowContent, [.init(id: id, issuer: "issuer", username: "username", TOTPCode: "totp", isFavourite: false)])
    }

    func test_PresenterReturnsLatestCorrectFirstValueOnSettingOutput() {
        let mock = AuthenticatorListPresenterServiceMock()
        let sut = makeSUT(mock: mock, cycleLength: 30)
        let spy = AuthenticatorListPresenterSpy()
        sut.receive(currentDate: (Date(timeIntervalSince1970: april_21_2022_222500_GMT)))
        sut.receive(currentDate: (Date(timeIntervalSince1970: april_21_2022_222505_GMT)))
        sut.output = spy
        XCTAssertEqual(spy.receivedCountDowns.count, 1)
        XCTAssertEqual(spy.receivedCountDowns.last, "25")
    }

    func test_PresenterOutputsNewRowContent_WhenCycleIsFinished() {
        let mock = AuthenticatorListPresenterServiceMock()
        let spy = AuthenticatorListPresenterSpy()
        let sut = makeSUT(mock: mock, cycleLength: 30)
        mock.getTOTPResult = "totp"
        sut.output = spy
        let id = UUID()
        sut.receive(result: .success([
            .init(id: id, issuer: "issuer", username: "username", secret: "secret", isFavourite: false)
        ]))
        XCTAssertEqual(spy.receivedSections.count, 1)
        XCTAssertEqual(spy.receivedSections.first?[0].rowContent, [.init(id: id, issuer: "issuer", username: "username", TOTPCode: "totp", isFavourite: false)])
        sut.receive(currentDate: Date(timeIntervalSince1970: april_21_2022_222505_GMT))
        XCTAssertEqual(spy.receivedSections.count, 1)
        mock.getTOTPResult = "totp2"
        sut.receive(currentDate: Date(timeIntervalSince1970: april_21_2022_222500_GMT))
        XCTAssertEqual(spy.receivedSections.count, 2)
        XCTAssertEqual(spy.receivedSections.last?[0].rowContent[0].TOTPCode, "totp2")
    }

    func test_PresenterCallsDeleteService_OnDeleteCalles() {
        let id = UUID()
        let mock = AuthenticatorListPresenterServiceMock()
        let sut = makeSUT(mock: mock)
        sut.receive(result: .success([
            AuthenticatorAccountModel(id: id, issuer: "", username: "", secret: "", isFavourite: false)
        ]))
        sut.delete(atOffset: 0)
        XCTAssertEqual(mock.deleteCallIDCount, 1)
        XCTAssertEqual(mock.deleteCallIDS.last, id)
    }

    func test_PresenterDoesntOutputDeletedAccount_IfDeleteSucceeds() {
        let id = UUID()
        let account = AuthenticatorAccountModel(id: id, issuer: "issuer", username: "username", secret: "secret", isFavourite: false)
        let mock = AuthenticatorListPresenterServiceMock()
        let spy = AuthenticatorListPresenterSpy()
        let sut = makeSUT(mock: mock)
        sut.output = spy
        sut.receive(result: .success([account]))
        XCTAssertEqual(spy.receivedSections.count, 1)
        XCTAssertEqual(spy.receivedSections.last?[0].rowContent[0].id, account.id)
        sut.delete(atOffset: 0)
        XCTAssertEqual(mock.deleteCallIDCount, 1)
    }

    func test_PresenterCallService_IfReceivesDeleteID() {
        let mock = AuthenticatorListPresenterServiceMock()
        let sut = makeSUT(mock: mock)
        let id = UUID()
        sut.delete(id: id)
        XCTAssertEqual(mock.deleteCallIDS.count, 1)
        XCTAssertEqual(mock.deleteCallIDS.last, id)
    }

    func test_presenterDoesNothing_ifDeleteIdIsNotFound() {
        let mock = AuthenticatorListPresenterServiceMock()
        let sut = makeSUT(mock: mock)
        sut.delete(atOffset: 100)
        XCTAssertEqual(mock.deleteCallIDS.count, 0)
    }

    func test_presenterCallsService_ifReceivesFavouriteID() {
        let mock = AuthenticatorListPresenterServiceMock()
        let sut = makeSUT(mock: mock)
        let id = UUID()
        sut.favourite(id: id)
        XCTAssertEqual(mock.favouriteCallIDS.count, 1)
        XCTAssertEqual(mock.favouriteCallIDS.last, id)
    }

    func test_presenterShowsFavouriteSection_ifReceivesFavouriteModel() {
        let mock = AuthenticatorListPresenterServiceMock()
        let spy = AuthenticatorListPresenterSpy()
        let sut = makeSUT(mock: mock)
        sut.output = spy
        sut.receive(result: .success([
            .init(id: UUID(), issuer: "issuer1", username: "", secret: "", isFavourite: true),
            .init(id: UUID(), issuer: "issuer2", username: "", secret: "", isFavourite: false),
            .init(id: UUID(), issuer: "issuer3", username: "", secret: "", isFavourite: true),
        ]))
        XCTAssertEqual(spy.receivedSections.count, 1)
        XCTAssertEqual(spy.receivedSections[0].count, 2)
        XCTAssertEqual(spy.receivedSections[0][0].title, "Favourites")
        XCTAssertEqual(spy.receivedSections[0][0].rowContent.count, 2)
        XCTAssertEqual(spy.receivedSections[0][0].rowContent[0].issuer, "issuer1")
        XCTAssertEqual(spy.receivedSections[0][0].rowContent[1].issuer, "issuer3")
        XCTAssertEqual(spy.receivedSections[0][1].title, "Accounts")
        XCTAssertEqual(spy.receivedSections[0][1].rowContent.count, 1)
        XCTAssertEqual(spy.receivedSections[0][1].rowContent[0].issuer, "issuer2")

    }

    func test_PresenterDoesntRecalculateData_IfCalledLoadWhenCurrentCycleIsCalculated() {
        let mock = AuthenticatorListPresenterServiceMock()
        let spy = AuthenticatorListPresenterSpy()
        let sut = makeSUT(mock: mock, cycleLength: 30)
        sut.output = spy
        sut.receive(currentDate: Date(timeIntervalSince1970: april_21_2022_222500_GMT))
        XCTAssertEqual(spy.receivedSections.count, 1)
        sut.refresh(date: Date(timeIntervalSince1970: april_21_2022_222505_GMT))
        XCTAssertEqual(spy.receivedSections.count, 1)
        sut.refresh(date: Date(timeIntervalSince1970: april_21_2022_222505_GMT).addingTimeInterval(1000))
        XCTAssertEqual(spy.receivedSections.count, 2)
    }

    func test_presenterCanFilter() {
        let mock = AuthenticatorListPresenterServiceMock()
        let spy = AuthenticatorListPresenterSpy()
        let sut = makeSUT(mock: mock, cycleLength: 30)
        sut.output = spy
        sut.receive(result: .success([
            .init(id: UUID(), issuer: "issuer2", username: "user", secret: "", isFavourite: false),
            .init(id: UUID(), issuer: "otherIssuer", username: "user", secret: "", isFavourite: false)
        ]))
        sut.filter(by: "other")
        XCTAssertEqual(spy.receivedSections.count, 2)
        XCTAssertEqual(spy.receivedSections.last?[0].rowContent[0].issuer, "otherIssuer")
        sut.filter(by: "issuer2")
        XCTAssertEqual(spy.receivedSections.count, 3)
        XCTAssertEqual(spy.receivedSections.last?[0].rowContent[0].issuer, "issuer2")
        sut.filter(by: "nonexistant")
        XCTAssertEqual(spy.receivedSections.count, 4)
        XCTAssertEqual(spy.receivedSections.last?[0].rowContent.isEmpty, true)
        sut.filter(by: "")
        XCTAssertEqual(spy.receivedSections.count, 5)
        XCTAssertEqual(spy.receivedSections.last?[0].rowContent.count, 2)
    }

    func test_presenterForwardsError_ifReceivesError() {
        let error = SomeError(message: "error")
        let sut = makeSUT()
        let spy = AuthenticatorListPresenterSpy()
        sut.errorOutput = spy
        sut.receive(error: error)
        XCTAssertEqual(spy.receivedErrors.count, 1)
        XCTAssertEqual(spy.receivedErrors.last as? SomeError, error)
    }

    func test_presenterForwardsError_ifReceivesLoadError() {
        let error = SomeError(message: "error")
        let sut = makeSUT()
        let spy = AuthenticatorListPresenterSpy()
        sut.errorOutput = spy
        sut.receive(result: .failure(error))
        XCTAssertEqual(spy.receivedErrors.count, 1)
        XCTAssertEqual(spy.receivedErrors.last as? SomeError, error)
    }

    private func testTimeIntervalLeftIfMinuteIs00(epochTime: TimeInterval, cycleLength: Int, expectedResult: String) {
        let mock = AuthenticatorListPresenterServiceMock()
        let sut = makeSUT(mock: mock, cycleLength: cycleLength)
        let minuteStartDate = Date(timeIntervalSince1970: epochTime)
        let spy = AuthenticatorListPresenterSpy()
        sut.output = spy
        sut.receive(currentDate: minuteStartDate)
        XCTAssertEqual(spy.receivedCountDowns.count, 1)
        XCTAssertEqual(spy.receivedCountDowns.first, expectedResult)
    }

    private func testMultipleInputsInSuccession(
        sut: AuthenticatorListBusiness,
        mock: AuthenticatorListPresenterServiceMock,
        spy: AuthenticatorListPresenterSpy,
        inputs: [(epoch: TimeInterval, expected: String)])
    {
        var iterations = 0
        for input in inputs {
            iterations += 1
            let date = Date(timeIntervalSince1970: input.epoch)
            sut.receive(currentDate: date)
            XCTAssertEqual(spy.receivedCountDowns.count, iterations)
            XCTAssertEqual(spy.receivedCountDowns.last, input.expected)
        }
    }

    func makeSUT(mock: AuthenticatorListPresenterServiceMock = .init(), cycleLength: Int = 30) -> AuthenticatorListBusiness {
        let sut = AuthenticatorListBusiness(service: mock, cycleLength: cycleLength)
        weakSUT = sut
        return sut
    }
}

struct SomeError: Error, Equatable {
    let message: String
}

class AuthenticatorListPresenterSpy: AuthenticatorListViewOutput, AuthenticatorListErrorOutput {
    var receivedCountDowns: [String] = []
    var receivedSections: [[AuthencticatorListSection]] = []
    var receivedErrors: [Error] = []

    func receive(content: AuthenticatorListContent) {
        receivedSections.append(content)
    }

    func receive(countDown: String) {
        receivedCountDowns.append(countDown)
    }

    func receive(error: Error) {
        receivedErrors.append(error)
    }
}

class AuthenticatorListPresenterServiceMock: AuthenticatorListBusinessService {
    var loadAccountCallCount = 0
    var getTOTPResult: String = ""
    var deleteCallIDS: [UUID] = []
    var deleteCallIDCount: Int {
        deleteCallIDS.count
    }
    var favouriteCallIDS: [UUID] = []
    var updateCalls: [AuthenticatorAccountModel] = []

    func loadAccounts() {
        loadAccountCallCount += 1
    }

    func getTOTP(secret: String, timeInterval: Int, date: Date) -> String {
        getTOTPResult
    }

    func deleteAccount(id: UUID) {
        deleteCallIDS.append(id)
    }

    func favourite(_ account: UUID) {
        favouriteCallIDS.append(account)
    }

    func update(_ account: AuthenticatorAccountModel) {
        updateCalls.append(account)
    }
}
