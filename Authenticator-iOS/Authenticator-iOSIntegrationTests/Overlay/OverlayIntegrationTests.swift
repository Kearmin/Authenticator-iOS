//
//  OverlayIntegrationTests.swift
//  Authenticator-iOSIntegrationTests
//
//  Created by Kertész Jenő Ármin on 2022. 06. 16..
//

import XCTest
@testable import Authenticator_iOS
import Combine
import OverlayView
import OverlayBusiness

class OverlayIntegrationTests: XCTestCase {
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
    }

    func test_Overlay_HasCorrectImage() {
        let sut = makeSUT()
        sut.viewController.loadViewIfNeeded()
        XCTAssertEqual(sut.view.imageName, Images.zyzzSticker.rawValue)
    }

    func test_OverlaySendsLockEvent_OnViewDidLoad() {
        let sut = makeSUT()
        let spy = sut.eventPublisherSpy
        sut.viewController.loadViewIfNeeded()
        XCTAssertEqual(spy.resultCount, 1)
        XCTAssertEqual(spy.values.first, .lock)
    }

    func test_Overlay_DoesNothingWhenReceivesLockEvent_AndStillLocked() {
        let sut = makeSUT()
        sut.viewController.loadViewIfNeeded()
        let spy = sut.eventPublisherSpy
        for _ in (0...10) {
            sut.loader.didBecomeActiveSubject.send()
            XCTAssertEqual(spy.resultCount, 0)
        }
    }

    func test_OverlayRequestAuthentication_IfReceivesActiveWhileLocked() {
        let sut = makeSUT()
        sut.viewController.loadViewIfNeeded()
        sut.loader.didBecomeActiveSubject.send()
        XCTAssertEqual(sut.loader.authenticationLoaderCallCount, 1)
    }

    func test_OverlaySendsUnlockEvent_IfAuthenticationISSuccessful() {
        let sut = makeSUT()
        sut.viewController.loadViewIfNeeded()
        sut.loader.didBecomeActiveSubject.send()
        let spy = sut.eventPublisherSpy
        sut.loader.authenticationLoader.completeLoading(with: true)
        XCTAssertEqual(spy.resultCount, 1)
        XCTAssertEqual(spy.values.first, .unlock)
    }

    func test_OverlayDoesNotRequestAuthentication_IfAnotherIsInProgress() {
        let sut = makeSUT()
        sut.viewController.loadViewIfNeeded()
        sut.loader.didBecomeActiveSubject.send()
        let spy = sut.eventPublisherSpy
        for _ in (0...10) {
            sut.loader.didBecomeActiveSubject.send()
            XCTAssertEqual(spy.resultCount, 0)
        }
    }

    func test_OverlaySkipsNextUnlockEvent_IFAuthenticationFails() {
        let sut = makeSUT()
        sut.viewController.loadViewIfNeeded()
        sut.loader.didBecomeActiveSubject.send()
        sut.loader.authenticationLoader.completeLoadingWithError(with: anError())
        sut.loader.didBecomeActiveSubject.send()
        XCTAssertEqual(sut.loader.authenticationLoaderCallCount, 1)
        sut.loader.didBecomeActiveSubject.send()
        XCTAssertEqual(sut.loader.authenticationLoaderCallCount, 2)
    }

    func test_OverlaySkipsNextUnlockEvent_IFAuthenticationReturnsFalse() {
        let sut = makeSUT()
        sut.viewController.loadViewIfNeeded()
        sut.loader.didBecomeActiveSubject.send()
        sut.loader.authenticationLoader.completeLoading(with: false)
        sut.loader.didBecomeActiveSubject.send()
        XCTAssertEqual(sut.loader.authenticationLoaderCallCount, 1)
        sut.loader.didBecomeActiveSubject.send()
        XCTAssertEqual(sut.loader.authenticationLoaderCallCount, 2)
    }

    func test_OverlayRequestsAuthentication_IfUnlockButtonIsPressed() {
        let sut = makeSUT()
        sut.viewController.loadViewIfNeeded()
        sut.view.onUnlockDidPress()
        XCTAssertEqual(sut.loader.authenticationLoaderCallCount, 1)
    }

    func test_OverlayLocks_IfReceivesWillResignWhileUnlocked() {
        let sut = makeSUT()
        let spy = sut.eventPublisherSpy
        sut.loader.willResignActiveSubject.send()
        XCTAssertEqual(spy.resultCount, 1)
        XCTAssertEqual(spy.values.first, .lock)
    }

    func test_OverlayTrackEvents() {
        let sut = makeSUT()
        sut.engageEventPublisher()
        sut.viewController.loadViewIfNeeded()
        XCTAssertEqual(sut.analyticsMock.callCount, 1)
        XCTAssertEqual(sut.analyticsMock.calls.last, .init(name: "App lock overlay appeared", properties: nil))
        sut.loader.didBecomeActiveSubject.send()
        sut.loader.authenticationLoader.completeLoading(with: true)
        XCTAssertEqual(sut.analyticsMock.callCount, 2)
        XCTAssertEqual(sut.analyticsMock.calls.last, .init(name: "App lock overlay disappeared", properties: nil))
    }

    func makeSUT() -> TestEnvironment {
        .init()
    }

    class TestEnvironment {
        let viewController: OverlayViewController
        var view: OverlayView {
            viewController.rootView
        }
        let eventPublisher: OverlayEventPublisher
        var eventPublisherSpy: PublisherSpy<OverlayEvent, Never> { .init(eventPublisher) }
        let analyticsMock: AnalyticsMock
        let loader: OverlayLoader

        private var eventSpyReference: PublisherSpy<OverlayEvent, Never>?
        func engageEventPublisher() {
            eventSpyReference = eventPublisherSpy
        }

        init() {
            let analytics = AnalyticsMock()
            let loader = OverlayLoader()
            let (viewController, eventPublisher) = OverlayComposer.overlay(dependencies: .init(
                willResignActivePublisher: loader.willResignActivePublisher,
                didBecomeActivePublisher: loader.didBecomeActivePublisher,
                authentication: loader.authentication,
                analytics: analytics))
            self.loader = loader
            self.viewController = viewController
            self.eventPublisher = eventPublisher
            self.analyticsMock = analytics
        }
    }

    class OverlayLoader {
        let willResignActiveSubject = PassthroughSubject<Void, Never>()
        var willResignActivePublisher: AnyPublisher<Void, Never> {
            willResignActiveSubject.eraseToAnyPublisher()
        }

        let didBecomeActiveSubject = PassthroughSubject<Void, Never>()
        var didBecomeActivePublisher: AnyPublisher<Void, Never> {
            didBecomeActiveSubject.eraseToAnyPublisher()
        }

        lazy var authentication: () -> AnyPublisher<Bool, Error> = authenticationLoader.startRequest
        let authenticationLoader = LoaderStub<Bool, Error>()
        var authenticationLoaderCallCount: Int { authenticationLoader.requestCallCount }
    }
}
