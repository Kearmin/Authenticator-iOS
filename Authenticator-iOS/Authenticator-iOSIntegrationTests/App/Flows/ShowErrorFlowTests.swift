//
//  ShowErrorFlowTests.swift
//  Authenticator-iOSIntegrationTests
//
//  Created by Kertész Jenő Ármin on 2022. 06. 18..
//

import Foundation
import XCTest
@testable import Authenticator_iOS

class ShowErrorFlowTests: XCTestCase {
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
    }

    func test_FlowShows_CorrectErrorMessageAndTitle() throws {
        let flow = ShowErrorFlow()
        let expected = ErrorContext(
            title: "Title",
            message: "Message")
        let source = ViewControllerSpy()
        flow.start(context: expected, source: source)
        let alertController = try XCTUnwrap(source.capturedViewController as? UIAlertController)
        XCTAssertEqual(alertController.title, expected.title)
        XCTAssertEqual(alertController.message, expected.message)
    }

    func test_Flow_HasOkAction() throws {
        let flow = ShowErrorFlow()
        let expected = ErrorContext(title: "", message: "")
        let source = ViewControllerSpy()
        flow.start(context: expected, source: source)
        let alertController = try XCTUnwrap(source.capturedViewController as? UIAlertController)
        XCTAssertEqual(alertController.actions.count, 1)
        XCTAssertEqual(alertController.actions.first?.title, "Ok")
    }
}
