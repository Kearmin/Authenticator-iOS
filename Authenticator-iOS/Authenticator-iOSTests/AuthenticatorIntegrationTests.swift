//
//  AuthenticatorIntegrationTests.swift
//  Authenticator-iOSTests
//
//  Created by Kertész Jenő Ármin on 2022. 04. 22..
//

import XCTest
import AuthenticatorListView
import AuthenticatorListBusiness
@testable import Authenticator_iOS

class AuthenticatorIntegrationTests: XCTestCase {

    weak var weakSUT: AuthenticatorListComposer?

    // 2022. May 1., Sunday 20:29:00
    private let dateAt00minute = Date(timeIntervalSince1970: 1651436940)
    // 2022. May 1., Sunday 20:29:20
    private let dateAt20minute = Date(timeIntervalSince1970: 1651436960)

    override func tearDown() {
        XCTAssertNil(weakSUT)
    }

    func test_CanInitComposer() {
        _ = makeSUT()
    }

    func test_ComposerAttechesToCurrentTimeProvider() {
        let env = makeSUT()
        XCTAssertNotNil(env.mock.receiveCurrentDate)
    }

    func test_ComposerCallsLoadOnViewDidLoad() {
        let env = makeSUT()
        XCTAssertEqual(env.mock.loadAccountCallCount, 1)
    }

    func test_ComposerCanDisplayCurrentTimeLeftWith30SecCycles() {
        let env = makeSUT()
        env.mock.receiveCurrentDate!(dateAt00minute)
        RunLoop.current.runUntilCurrentDate()
        XCTAssertEqual(env.sut.viewModel.countDownSeconds, "30")
        env.mock.receiveCurrentDate!(dateAt20minute)
        RunLoop.current.runUntilCurrentDate()
        XCTAssertEqual(env.sut.viewModel.countDownSeconds, "10")
    }

    func test_ComposerCanDisplayRows() {
        let env = makeSUT()
        let ids = [UUID(), UUID(), UUID()]
        env.sut.presenter.receive(result: .success(
            ids.map { .init(
                id: $0,
                issuer: "issuer\($0)",
                username: "username\($0)",
                secret: "secret")
            }
        ))
        RunLoop.main.runUntilCurrentDate()
        XCTAssertEqual(env.sut.viewModel.rows, ids.map {
            .init(id: $0,
                  issuer: "issuer\($0)",
                  username: "username\($0)",
                  TOTPCode: env.mock.totp,
                  onTrailingSwipeAction: {})
        })
    }

    func test_ComposerCanDeleteRow() {
        let env = makeSUT()
        let id = UUID()
        env.sut.presenter.receive(result: .success([
            .init(id: id, issuer: "issuer", username: "username", secret: "secret"),
        ]))
        RunLoop.main.runUntilCurrentDate()
        env.sut.viewModel.rows[0].onTrailingSwipeAction()
        RunLoop.main.runUntilCurrentDate()
        XCTAssertEqual(env.mock.deleteAccountCallIds.count, 1)
        XCTAssertEqual(env.mock.deleteAccountCallIds.removeFirst(), id)
        XCTAssertEqual(env.sut.viewModel.rows, [])
    }

    func test_composerHasAddButtonInNavigationRight() {
        let env = makeSUT()
        XCTAssertEqual(env.sut.navigationItem.rightBarButtonItem?.systemItem, .add)
    }

    func test_composerCallDelegateWhenSystemButtonIsPressed() {
        let env = makeSUT()
        env.sut.navigationItem.rightBarButtonItem?.simulateTap()
        RunLoop.current.runUntilCurrentDate()
        XCTAssertIdentical(env.componentSpy.didPressCalls.first, env.sut)
    }

    func test_composerReloadsIfAppEntersForeground() async {
        let env = makeSUT()
        await sendAppEventAndWaitForExpectetions(env: env, callCount: 2)
        await sendAppEventAndWaitForExpectetions(env: env, callCount: 3)
    }

    private func sendAppEventAndWaitForExpectetions(env: TestEnvironment, callCount: Int) async {
        env.mock.expectation = expectation(description: "")
        env.appEventObservable.appDidEnterForeground()
        await waitForExpectations(timeout: 0.1)
        XCTAssertEqual(env.mock.loadAccountCallCount, callCount)
    }

    func makeSUT() -> TestEnvironment {
        let env = TestEnvironment()
        weakSUT = env.sut
        env.sut.triggerLifecycleIfNeeded()
        return env
    }

    class TestEnvironment {
        let sut: AuthenticatorListComposer
        let appEventObservable :AppEventObservable
        let mock: AuthenticatorListPresenterMock
        let componentSpy: AuthenticatorListComposerDelegateSpy

        init() {
            mock = .init()
            appEventObservable = .init()
            componentSpy = .init()
            let viewModel = AuthenticatorListViewModel()
            let view = AuthenticatorListView(viewModel: viewModel)
            let presenter = AuthenticatorListPresenter(service: mock)
            sut = .init(
                rootView: view,
                viewModel: viewModel,
                presenter: presenter,
                appEventObservable: appEventObservable)
            sut.delegate = componentSpy
        }
    }

    class AuthenticatorListComposerDelegateSpy: AuthenticatorListComposerDelegate {
        var didPressCalls: [AuthenticatorListComposer] = []
        func didPressAddAccountButton(_ authenticatorListViewComposer: AuthenticatorListComposer) {
            didPressCalls.append(authenticatorListViewComposer)
        }
    }

    class AuthenticatorListPresenterMock: AuthenticatorListPresenterService {
        var totp: String = ""
        var loadAccountCallCount = 0
        var deleteAccountCallIds: [UUID] = []
        var expectation: XCTestExpectation?

        func loadAccounts() {
            loadAccountCallCount += 1
            expectation?.fulfill()
        }

        func getTOTP(secret: String, timeInterval: Int, date: Date) -> String {
            totp
        }

        var receiveCurrentDate: ((Date) -> Void)?

        var cycleLength: Int = 30

        func deleteAccount(id: UUID) throws {
            deleteAccountCallIds.append(id)
        }
    }
}
