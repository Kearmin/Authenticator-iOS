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

class ViewControllerSpy: UIViewController {
    var capturedViewController: UIViewController?

    override func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
        capturedViewController = viewControllerToPresent
    }

    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        XCTAssertNotNil(capturedViewController, "Dismiss called on non presenting viewcontroller")
        capturedViewController = nil
    }
}

class AddAccountFlowTests: XCTestCase {
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
    }

    func test_FlowPresents_AddAccountViewController() throws {
        let sut = makeSUT()
        let capturedNavController = try XCTUnwrap(sut.spy.capturedViewController as? UINavigationController)
        XCTAssertIdentical(capturedNavController.viewControllers.first, sut.viewController)
    }

    func makeSUT() -> TestEnvironment {
        .init()
    }

    class TestEnvironment {
        let viewController: AddAccountViewController
        let eventSubject: PassthroughSubject<AddAccountEvent, Never>
        let flow: AddAccountFlow
        let spy: ViewControllerSpy

        init() {
            let viewController = AddAccountViewController(addAccountView: .init(frame: .zero, objectTypes: [])) { _ in }
            let eventSubject = PassthroughSubject<AddAccountEvent, Never>()
            let flow = AddAccountFlow {
                (viewController, eventSubject.eraseToAnyPublisher())
            }
            self.viewController = viewController
            self.eventSubject = eventSubject
            self.flow = flow
            self.spy = ViewControllerSpy()
            flow.start(with: spy)
        }
    }
}
