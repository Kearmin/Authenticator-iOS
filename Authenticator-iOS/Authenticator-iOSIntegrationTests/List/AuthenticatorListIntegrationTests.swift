// swiftlint:disable all
//  AuthenticatorListIntegrationTests.swift
//  Authenticator-iOSIntegrationTests
//
//  Created by Kertész Jenő Ármin on 2022. 05. 24..
//

import XCTest
import Combine
import UIKit
import AuthenticatorListBusiness
import AuthenticatorListView
@testable import Authenticator_iOS

class AuthenticatorListIntegrationTests: XCTestCase {
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
    }

    func test_ListHastTitle() {
        let env = makeSUT()
        XCTAssertEqual(env.sutViewController.title, "Authenticator")
    }

    func test_ListRequest_AccountsFromLoader() {
        let env = makeSUT()
        XCTAssertEqual(env.loader.readAccountsCallCount, 0, "Expected no calls before view loaded")
        env.sutViewController.loadViewIfNeeded()
        XCTAssertEqual(env.loader.readAccountsCallCount, 1, "Expected call when view loads")
    }

    func test_ListCanRender_MultipleNormalAccounts() {
        let model = anAccountModel()
        let model2 = anAccountModel()
        let model3 = anAccountModel()
        assertListCan(render: [model, model2, model3])
    }

    func test_ListCanRender_MultipleFavouriteAccounts() {
        let model = anAccountModel(isFavourite: true)
        let model2 = anAccountModel(isFavourite: true)
        let model3 = anAccountModel(isFavourite: true)
        assertListCan(render: [model, model2, model3])
    }

    func test_ListCanRender_MultipleFavouriteAndNormalAccounts() {
        let model = anAccountModel(isFavourite: true)
        let model2 = anAccountModel(isFavourite: true)
        let model3 = anAccountModel(isFavourite: true)
        let model4 = anAccountModel(isFavourite: false)
        let model5 = anAccountModel(isFavourite: false)
        let model6 = anAccountModel(isFavourite: false)
        assertListCan(render: [model, model2, model3, model4, model5, model6])
    }

    func test_ListRequests_CorrectTotp() {
        let env = makeSUT()
        env.sutViewController.loadViewIfNeeded()
        let model = anAccountModel()
        let model2 = anAccountModel(secret: "anotherSecret")
        let expectedParam = TOTPProviderMock.Params(secret: "secret", date: Date(), digits: 6, timeInterval: 30, algorithm: .sha1)
        let expectedParam2 = TOTPProviderMock.Params(secret: "anotherSecret", date: Date(), digits: 6, timeInterval: 30, algorithm: .sha1)
        env.loader.readAccountsLoader.completeLoading(with: [model, model2])
        XCTAssertEqual(env.totpProvider.capturedParams.count, 2)
        XCTAssertEqual(env.totpProvider.capturedParams.first, expectedParam)
        XCTAssertEqual(env.totpProvider.capturedParams.last, expectedParam2)
    }

    func test_viewController_HasAddButton() {
        let env = makeSUT()
        env.sutViewController.loadViewIfNeeded()
        XCTAssertEqual(env.sutViewController.navigationItem.rightBarButtonItem?.systemItem, .add)
    }

    func test_ViewControllerEmitsEvent_OnCorrectActions() {
        let env = makeSUT()
        let eventSpy = env.eventPublisherSpy
        env.sutViewController.loadViewIfNeeded()
        XCTAssertEqual(eventSpy.values.count, 1)
        XCTAssertEqual(eventSpy.values.first, .viewDidLoad)
        env.sutViewController.navigationItem.rightBarButtonItem?.simulateTap()
        XCTAssertEqual(eventSpy.values.count, 2)
        XCTAssertEqual(eventSpy.values.last, .addAccountDidPress)
    }

    func test_ListCanRender_CountDown() {
        let env = makeSUT()
        let countDownSpy = PublisherSpy(env.sutViewModel.$countDownSeconds.dropFirst().eraseToAnyPublisher())
        let date_5Sec = 1654791115.0
        let date_17Sec = 1654791133.0
        let date_28Sec = 1654791152.0
        let date_30Sec = 1654791150.0
        assertList(
            canRender: [(date_5Sec, "5"), (date_17Sec, "17"), (date_28Sec, "28"), (date_30Sec, "30")],
            countDownSpy: countDownSpy,
            clockLoader: env.loader.clockSubject)
    }

    func test_ListFiltersAccountsWithMatchingIssuer_BasedOnSearchText() {
        let expected: [AuthenticatorAccountModel] = [
            anAccountModel(issuer: "found", isFavourite: false),
            anAccountModel(issuer: "found", isFavourite: true)
        ]
        let filteredOut: [AuthenticatorAccountModel] = [
            anAccountModel(issuer: "x", isFavourite: false),
            anAccountModel(issuer: "x", isFavourite: true)
        ]
        assertList(renders: expected, from: expected + filteredOut, filterText: "fou")
    }

    func test_ListFiltersAccountsWithMatchingUsername_BasedOnSearchText() {
        let expected: [AuthenticatorAccountModel] = [
            anAccountModel(username: "found", isFavourite: false),
            anAccountModel(username: "found", isFavourite: true)
        ]
        let filteredOut: [AuthenticatorAccountModel] = [
            anAccountModel(username: "x", isFavourite: false),
            anAccountModel(username: "x", isFavourite: true)
        ]
        assertList(renders: expected, from: expected + filteredOut, filterText: "fou")
    }

    func test_ListPastesTOTPToClipBoard_IfCellIsClicked() {
        let model = anAccountModel()
        let env = makeSUT()
        env.sutViewController.loadViewIfNeeded()
        let spy = PublisherSpy(env.sutViewModel.$sections.dropFirst().eraseToAnyPublisher())
        env.totpProvider.result = "someTOTP"
        env.loader.readAccountsLoader.completeLoading(with: [model])
        spy.values.first?.accountSection.rows[0].onDidPress()
        XCTAssertEqual(UIPasteboard.general.string, "someTOTP")
    }

    func test_ListShowsToast_IfCellIsClicked() {
        let model = anAccountModel()
        let env = makeSUT()
        env.sutViewController.loadViewIfNeeded()
        let sectionSpy = PublisherSpy(env.sutViewModel.$sections.dropFirst().eraseToAnyPublisher())
        let toastSpy = PublisherSpy(env.sutViewModel.$toast.dropFirst().eraseToAnyPublisher())
        env.loader.readAccountsLoader.completeLoading(with: [model])
        sectionSpy.values.first?.accountSection.rows[0].onDidPress()
        XCTAssertEqual(toastSpy.resultCount, 1)
        XCTAssertEqual(toastSpy.values.first, "Copied to clipboard")
    }

    func test_ListDeletesAccount_IfDeleteIsClicked() throws {
        let model = anAccountModel()
        let toDeleteModel = anAccountModel()
        let env = makeSUT()
        env.sutViewController.loadViewIfNeeded()
        let eventSpy = env.eventPublisherSpy
        let spy = PublisherSpy(env.sutViewModel.$sections.dropFirst().eraseToAnyPublisher())
        env.loader.readAccountsLoader.completeLoading(with: [model, toDeleteModel])
        spy.values.first?.accountSection.rows[1].onDeletePress()
        XCTAssertEqual(eventSpy.resultCount, 1)
        let deleteEvent = try XCTUnwrap(eventSpy.values.first)
        XCTAssertEqual(deleteEvent, .deleteAccountDidPress(.init(callback: {})))
        if case let ListEvent.deleteAccountDidPress(context) = deleteEvent {
            context.callback()
            XCTAssertEqual(env.loader.deleteCallCount, 1)
            XCTAssertEqual(env.loader.deleteCallIDs.first, toDeleteModel.id)
        } else {
            XCTFail("Expected .deleteAccountDidPress")
        }
    }

    func test_ListEditsAccount_IfEditIsClicked() throws {
        let model = anAccountModel()
        let toEditModel = anAccountModel()
        let env = makeSUT()
        env.sutViewController.loadViewIfNeeded()
        let eventSpy = env.eventPublisherSpy
        let spy = PublisherSpy(env.sutViewModel.$sections.dropFirst().eraseToAnyPublisher())
        env.loader.readAccountsLoader.completeLoading(with: [model, toEditModel])
        spy.values.first?.accountSection.rows[1].onEditPress()
        XCTAssertEqual(eventSpy.resultCount, 1)
        let editEvent = try XCTUnwrap(eventSpy.values.first)
        let row = AuthenticatorListRowContent(id: toEditModel.id, issuer: toEditModel.issuer, username: toEditModel.username, TOTPCode: "", isFavourite: toEditModel.isFavourite)
        XCTAssertEqual(editEvent, .editDidPress(.init(item: row, callback: {_,_ in })))
        if case let ListEvent.editDidPress(context) = editEvent {
            context.callback("newIssuer", "newUsername")
            XCTAssertEqual(env.loader.updateCallCount, 1)
            let capturedItem = try XCTUnwrap(env.loader.updateCallItems.first)
            XCTAssertEqual(capturedItem.username, "newUsername")
            XCTAssertEqual(capturedItem.issuer, "newIssuer")
        } else {
            XCTFail("Expected .editAccountDidPress")
        }
    }

    func test_ListfavouritesAccount_IfFavouriteIsClicked() throws {
        let model = anAccountModel()
        let toFavouriteModel = anAccountModel()
        let env = makeSUT()
        env.sutViewController.loadViewIfNeeded()
        let spy = PublisherSpy(env.sutViewModel.$sections.dropFirst().eraseToAnyPublisher())
        env.loader.readAccountsLoader.completeLoading(with: [model, toFavouriteModel])
        spy.values.first?.accountSection.rows[1].onFavouritePress()
        XCTAssertEqual(env.loader.favouriteCallCount, 1)
        XCTAssertEqual(env.loader.favouriteCallIDs.first, toFavouriteModel.id)
    }

    func test_ListReload_ifRefreshTriggered() {
        let env = makeSUT()
        env.loader.refreshSubject.send()
        XCTAssertEqual(env.loader.readAccountsLoader.requestCallCount, 1)
        env.loader.refreshSubject.send()
        XCTAssertEqual(env.loader.readAccountsLoader.requestCallCount, 2)
    }

    private func assertList(
        renders filteredAccounts: [AuthenticatorAccountModel],
        from nonFilteredAccounts: [AuthenticatorAccountModel],
        filterText: String
    ) {
        let env = makeSUT()
        env.sutViewController.loadViewIfNeeded()
        env.loader.readAccountsLoader.completeLoading(with: nonFilteredAccounts)
        let expectation = expectation(description: "filter expectation")
        let spy = PublisherSpy(env.sutViewModel.$sections.dropFirst().eraseToAnyPublisher(), expectation: expectation)
        env.sutViewModel.searchText = filterText
        waitForExpectations(timeout: 1.0) { _ in
            XCTAssertEqual(spy.resultCount, 1)
            self.assertThat(spy.values[0], isRendering: filteredAccounts)
        }
    }

    private func assertList(canRender dates: [(TimeInterval, String)], countDownSpy: PublisherSpy<String, Never>, clockLoader: PassthroughSubject<Date, Never>) {
        for date in dates {
            clockLoader.send(Date(timeIntervalSince1970: date.0))
            XCTAssertEqual(countDownSpy.values.last, date.1)
        }
        XCTAssertEqual(countDownSpy.resultCount, dates.count)
    }

    private func assertListCan(render models: [AuthenticatorAccountModel]) {
        let env = makeSUT()
        let totp = "totp"
        env.totpProvider.result = totp
        env.sutViewController.loadViewIfNeeded()
        let spy = PublisherSpy(
            env.sutViewModel.$sections.dropFirst().eraseToAnyPublisher()
        )
        env.loader.readAccountsLoader.completeLoading(with: models)
        XCTAssertEqual(spy.values.count, 1)
        self.assertThat(spy.values[0], isRendering: models, totp: totp)
    }

    private func assertThat(
        _ sections: [AuthenticatorListViewSection],
        isRendering accounts: [AuthenticatorAccountModel],
        totp: String = "",
        file: StaticString = #filePath,
        line: UInt = #line) {
            XCTAssertEqual(sections.flatMap({ $0.rows }).count, accounts.count, "account count", file: file, line: line)

            let favouriteAccounts = accounts.filter({ $0.isFavourite })
            let normalAccounts = accounts.filter({ !$0.isFavourite })

            normalAccounts.enumerated().forEach { index, account in
                XCTAssertEqual(sections.accountSection.rows[index].id, account.id)
                XCTAssertEqual(sections.accountSection.rows[index].username, account.username)
                XCTAssertEqual(sections.accountSection.rows[index].issuer, account.issuer)
                XCTAssertEqual(sections.accountSection.rows[index].isFavourite, account.isFavourite)
                XCTAssertEqual(sections.accountSection.rows[index].TOTPCode, totp)
            }
            guard !favouriteAccounts.isEmpty else { return }
            favouriteAccounts.enumerated().forEach { index, account in
                XCTAssertEqual(sections.favouriteSection.rows[index].id, account.id)
                XCTAssertEqual(sections.favouriteSection.rows[index].username, account.username)
                XCTAssertEqual(sections.favouriteSection.rows[index].issuer, account.issuer)
                XCTAssertEqual(sections.favouriteSection.rows[index].isFavourite, account.isFavourite)
                XCTAssertEqual(sections.favouriteSection.rows[index].TOTPCode, totp)
            }
        }

    private func makeSUT() -> TestEnvironment {
        let env = TestEnvironment()
        trackForMemoryLeaks(env.loader)
        return env
    }

    func anAccountModel(
        issuer: String = "issuer",
        username: String = "username",
        secret: String = "secret",
        isFavourite: Bool = false) -> AuthenticatorAccountModel
    {
        .init(id: UUID(), issuer: issuer, username: username, secret: secret, isFavourite: isFavourite)
    }

    class TestEnvironment {
        let loader: ListLoaderStub
        let sutView: AuthenticatorListView
        let sutViewController: AuthenticatorListViewController
        let sutViewModel: AuthenticatorListViewModel
        let totpProvider: TOTPProviderMock
        let eventPublisher: AnyPublisher<ListEvent, Never>
        let analyticsMock: AnalyticsMock

        var eventPublisherSpy: PublisherSpy<ListEvent, Never> {
            .init(eventPublisher)
        }

        init(loader: ListLoaderStub = .init()) {
            self.loader = loader
            let totpProvider = TOTPProviderMock()
            let analytics = AnalyticsMock()
            let (viewController, eventPublisher) = ListComposer.list(dependencies: .init(
                totpProvider: totpProvider,
                readAccounts: loader.readAccounts,
                delete: loader.delete,
                favourite: loader.favourite,
                update: loader.update,
                refreshPublisher: loader.refresh,
                clockPublisher: loader.clock,
                analytics: analytics)
            )
            self.eventPublisher = eventPublisher
            self.sutViewController = viewController
            self.sutView = sutViewController.rootView
            self.sutViewModel = sutViewController.viewModel
            self.totpProvider = totpProvider
            self.analyticsMock = analytics
        }
    }
}

extension Array where Element == AuthenticatorListViewSection {
    var hasFavouriteSection: Bool {
        count > 1
    }

    var favouriteSection: AuthenticatorListViewSection {
        guard hasFavouriteSection else {
            XCTFail("Expected to have favourite section")
            fatalError("Expected to have favourite section")
        }
        return self[0]
    }

    var accountSection: AuthenticatorListViewSection {
        if hasFavouriteSection {
            return self[1]
        } else {
            return self[0]
        }
    }
}
