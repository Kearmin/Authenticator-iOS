// swiftlint:disable all
//  AddAccountIntegrationTests.swift
//  Authenticator-iOSIntegrationTests
//
//  Created by Kertész Jenő Ármin on 2022. 06. 15..
//

import XCTest
@testable import Authenticator_iOS
import AddAccountView
import AddAccountBusiness
import AuthenticatorListBusiness
import Combine

class AddAccountIntegrationTests: XCTestCase {
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
    }

    func test_AddAccountHas_DoneButton() {
        let sut = makeSUT()
        sut.addAccountViewController.loadViewIfNeeded()
        XCTAssertEqual(sut.addAccountViewController.navigationItem.rightBarButtonItem?.systemItem, .done)
    }

    func test_AddAccount_SendsDoneEvent() {
        let sut = makeSUT()
        sut.addAccountViewController.loadViewIfNeeded()
        let eventSpy = sut.eventPublisherSpy
        sut.addAccountViewController.navigationItem.rightBarButtonItem?.simulateTap()
        XCTAssertEqual(eventSpy.resultCount, 1)
        XCTAssertEqual(eventSpy.values.first, .doneDidPress)
    }

    func test_AddAccountSavesNewAccount_IfQRCodeIsFound() {
        let sut = makeSUT()
        sut.addAccountViewController.loadViewIfNeeded()
        let eventSpy = sut.eventPublisherSpy
        sut.viewDelegate.didFindQRCode(code: correctTOTPCode)
        sut.loader.saveAccountLoader.completeLoading(with: ())
        XCTAssertEqual(eventSpy.resultCount, 1)
        if case let .didCreateAccount(account: account) = eventSpy.values.first {
            XCTAssertEqual(account.secret, "secret")
            XCTAssertEqual(account.issuer, "issuer")
            XCTAssertEqual(account.username, "label")
            XCTAssertEqual(account.isFavourite, false)
            XCTAssertEqual(account.createdAt, Date().timeIntervalSince1970, accuracy: 0.1)
        } else {
            XCTFail("Expected .didCreateAccount event")
        }
    }

    func test_AddAccountThrowsError_IfSaveFails() {
        let sut = makeSUT()
        sut.addAccountViewController.loadViewIfNeeded()
        let eventSpy = sut.eventPublisherSpy
        sut.viewDelegate.didFindQRCode(code: correctTOTPCode)
        let nserror = anError()
        sut.loader.saveAccountLoader.completeLoadingWithError(with: nserror)
        XCTAssertEqual(eventSpy.resultCount, 1)
        if case let .qrCodeReadDidFail(error: error) = eventSpy.values.first {
            XCTAssertEqual(error as NSError, nserror)
        } else {
            XCTFail("Expected .qrCodeReadDidFail event")
        }
    }

    func test_AddAccountThrowsError_IFQRCodeIsInvalid() {
        let sut = makeSUT()
        sut.addAccountViewController.loadViewIfNeeded()
        let eventSpy = sut.eventPublisherSpy
        sut.viewDelegate.didFindQRCode(code: incorrectTOTPCode)
        XCTAssertEqual(eventSpy.resultCount, 1)
        if case let .qrCodeReadDidFail(error: error) = eventSpy.values.first {
            XCTAssertNotNil(error.useCaseError)
        } else {
            XCTFail("Expected .qrCodeReadDidFail event")
        }
    }

    func test_AddAccountThrowsError_IfCameraFailsToStart() {
        let sut = makeSUT()
        sut.addAccountViewController.loadViewIfNeeded()
        let eventSpy = sut.eventPublisherSpy
        sut.viewDelegate.failedToStart()
        XCTAssertEqual(eventSpy.resultCount, 1)
        XCTAssertEqual(eventSpy.values.first, .failedToStartCamera)
    }

    func makeSUT() -> TestEnvironment {
        .init()
    }

    private var correctTOTPCode = "otpauth://totp/label?secret=secret&issuer=issuer"
    private var incorrectTOTPCode = "otpauth://hotp/label?secret=secret&issuer=issuer"

    class TestEnvironment {
        let addAccountViewController: AddAccountViewController
        let loader: AddAccountLoader
        let analyticsMock: AnalyticsMock
        let eventPublisher: AddAccountEventPublisher
        var eventPublisherSpy: PublisherSpy<AddAccountEvent, Never> { .init(eventPublisher.eraseToAnyPublisher()) }
        var viewDelegate: AddAccountViewDelegate {
            let delegate = addAccountViewController.addAccountView.delegate
            XCTAssertNotNil(delegate)
            return delegate!
        }

        init() {
            loader = .init()
            analyticsMock = .init()
            let (viewController, eventPublisher) = AddAccountComposer.addAccount(with: .init(
                        saveAccountPublisher: loader.saveAccount,
                        analytics: analyticsMock))
            self.eventPublisher = eventPublisher
            self.addAccountViewController = viewController
        }
    }

    class AddAccountLoader {
        lazy var saveAccount: (AuthenticatorAccountModel) -> AnyPublisher<Void, Error> = { [unowned self] model in
            capturedModels.append(model)
            return saveAccountLoader.startRequest()
        }
        let saveAccountLoader = LoaderStub<Void, Error>()
        var capturedModels: [AuthenticatorAccountModel] = []
    }
}

private extension Error {
    var useCaseError: AddAccountUseCaseErrors? {
        XCTAssertTrue(self is AddAccountUseCaseErrors)
        return self as? AddAccountUseCaseErrors
    }
}


extension AddAccountEvent: Equatable {
    public static func == (lhs: AddAccountEvent, rhs: AddAccountEvent) -> Bool {
        switch (lhs, rhs) {
        case (.doneDidPress, .doneDidPress):
            return true
        case (.failedToStartCamera, .failedToStartCamera):
            return true
        case (let .qrCodeReadDidFail(error: lhsError), let .qrCodeReadDidFail(error: rhsError)):
            return lhsError.useCaseError == rhsError.useCaseError
        case (let .didCreateAccount(account: lhsAccount), let .didCreateAccount(account: rhsAccount)):
            return lhsAccount == rhsAccount
        default:
            return false
        }
    }
}
