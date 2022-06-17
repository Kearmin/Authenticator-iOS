//
//  AddAccountFlow.swift
//  Authenticator-iOSIntegrationTests
//
//  Created by Kertész Jenő Ármin on 2022. 06. 16..
//

import XCTest
@testable import Authenticator_iOS
import AddAccountView
import Combine
import AuthenticatorListBusiness

class AddAccountFlowTests: XCTestCase {
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
    }

    func test_FlowPresents_AddAccountViewController() throws {
        let sut = makeSUT()
        XCTAssertNotNil(sut.sourceSpy.capturedRootViewController)
        XCTAssertIdentical(sut.sourceSpy.capturedAddAccountViewController, sut.addAccountViewControllerSpy)
    }

    func test_FlowDismissesView_ifNeeded() {
        let sut = makeSUT()
        sut.eventSubject.send(.doneDidPress)
        XCTAssertEqual(sut.addAccountViewControllerSpy.dismissCallCount, 1)
        let someAccount = AuthenticatorAccountModel(id: UUID(), issuer: "", username: "", secret: "")
        sut.eventSubject.send(.didCreateAccount(account: someAccount))
        XCTAssertEqual(sut.addAccountViewControllerSpy.dismissCallCount, 2)
    }

    func test_FlowShowsError_IfCameraFailsToStart() throws {
        let sut = makeSUT()
        sut.eventSubject.send(.failedToStartCamera)
        XCTAssertNotNil(sut.sourceSpy.capturedRootViewController)
        XCTAssertIdentical(sut.errorFlowSpy.capturedSource, sut.sourceSpy.capturedAddAccountViewController)
        XCTAssertEqual(sut.errorFlowSpy.capturedContext, .init(title: "Error", message: "Failed to open camera"))
    }

    func test_FlowShowsError_IfFailedToReadQRCode() {
        let message = "some message"
        let error = SomeError(message: message)
        let sut = makeSUT()
        sut.eventSubject.send(.qrCodeReadDidFail(error: error))
        XCTAssertEqual(sut.errorFlowSpy.capturedSource, sut.sourceSpy.capturedAddAccountViewController)
        XCTAssertEqual(sut.errorFlowSpy.capturedContext, .init(title: "Error", message: message))
    }

    func makeSUT() -> TestEnvironment {
        return .init()
    }

    class TestEnvironment {
        let addAccountViewControllerSpy: AddAccountViewControllerSpy
        let eventSubject: PassthroughSubject<AddAccountEvent, Never>
        let flow: AddAccountFlow
        let errorFlowSpy: ShowErrorFlowSpy
        let sourceSpy: ViewControllerSpy

        init() {
            let viewController = AddAccountViewControllerSpy(addAccountView: .init(frame: .zero, objectTypes: [])) { _ in }
            let eventSubject = PassthroughSubject<AddAccountEvent, Never>()
            let errorFlowSpy = ShowErrorFlowSpy()
            let addAccountFactory = {
                (viewController, eventSubject.eraseToAnyPublisher())
            }
            let flow = AddAccountFlow(
                addAccountFactory: addAccountFactory,
                showErrorFlow: errorFlowSpy)
            self.addAccountViewControllerSpy = viewController
            self.eventSubject = eventSubject
            self.flow = flow
            self.sourceSpy = ViewControllerSpy()
            self.errorFlowSpy = errorFlowSpy
            flow.start(with: sourceSpy)
        }
    }
}

class AddAccountViewControllerSpy: AddAccountViewController {
    var dismissCallCount = 0
    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        dismissCallCount += 1
    }
}

private extension ViewControllerSpy {
    var capturedAddAccountViewController: AddAccountViewController? {
        return capturedRootViewController as? AddAccountViewController
    }
}
