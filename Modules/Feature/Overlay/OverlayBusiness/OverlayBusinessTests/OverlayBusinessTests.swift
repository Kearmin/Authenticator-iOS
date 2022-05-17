//
//  OverlayBusinessTests.swift
//  OverlayBusinessTests
//
//  Created by Kertész Jenő Ármin on 2022. 05. 17..
//

import XCTest
import OverlayBusiness

class OverlayBusinessTests: XCTestCase {
    func test_UseCase_CanLockIfUnlocked() {
        let env = TestEnvironment()
        env.sut.lock()
        XCTAssertEqual(env.spy.shouldLockCount, 1)
    }

    func test_UseCase_shouldNotLockIfAlreadyLocked() {
        let env = TestEnvironment()
        env.sut.lock()
        env.sut.lock()
        XCTAssertEqual(env.spy.shouldLockCount, 1)
    }

    func test_Usecase_unlocksIfLockedAndAuthenticationSucceeds() {
        let env = TestEnvironment()
        env.sut.lock()
        env.sut.unlock()
        XCTAssertEqual(env.mock.authenticationCallCounts, 1)
        env.sut.receiveAuthenticationSuccess()
        XCTAssertEqual(env.spy.shouldUnlockCount, 1)
    }

    func test_Usecase_LocksAfterLockingAndSuccessfulUnlockingOnce() {
        let env = TestEnvironment()
        env.sut.lock()
        env.sut.unlock()
        env.sut.receiveAuthenticationSuccess()
        env.sut.lock()
        XCTAssertEqual(env.spy.shouldLockCount, 2)
    }

    func test_Usecase_StaysLockedIfAuthenticationSuccessIsNotCalled() {
        let env = TestEnvironment()
        env.sut.lock()
        env.sut.unlock()
        XCTAssertEqual(env.spy.shouldUnlockCount, 0)
    }

    func test_USecase_DoesntStartAuthenticationIfIsInInitialState() {
        let env = TestEnvironment()
        env.sut.unlock()
        XCTAssertEqual(env.mock.authenticationCallCounts, 0)
    }


    func test_USecase_DoesntStartAuthenticationIfAlreadyUnlocked() {
        let env = TestEnvironment()
        env.sut.lock()
        env.sut.unlock()
        env.sut.receiveAuthenticationSuccess()
        env.sut.unlock()
        XCTAssertEqual(env.spy.shouldUnlockCount, 1)
    }

    class TestEnvironment {
        let sut: OverlayAuthenticatorUseCase
        let spy: OutputSpy
        let mock: AuthenticationMock

        init() {
            mock = .init()
            spy = .init()
            sut = .init(output: spy, authenticationService: mock)
        }
    }

    class OutputSpy: OverlayAuthenticatorUseCaseOutput {
        var shouldLockCount = 0
        var shouldUnlockCount = 0

        func shouldLock() {
            shouldLockCount += 1
        }

        func shouldUnlock() {
            shouldUnlockCount += 1
        }
    }

    class AuthenticationMock: OverlayAuthenticatorUseCaseAuthenticationService {
        var authenticationCallCounts = 0

        func startAuthentication() {
            authenticationCallCounts += 1
        }
    }

    struct SomeError: Error { }
}
