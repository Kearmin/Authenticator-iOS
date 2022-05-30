//
//  OverlayPresenter.swift
//  OverlayBusiness
//
//  Created by Kertész Jenő Ármin on 2022. 05. 17..
//

import Foundation

public protocol OverlayAuthenticatorUseCaseOutput {
    func shouldLock()
    func shouldUnlock()
}

public protocol OverlayAuthenticatorUseCaseAuthenticationService {
    func startAuthentication()
}

public final class OverlayAuthenticatorUseCase {
    public let output: OverlayAuthenticatorUseCaseOutput
    public let authenticationService: OverlayAuthenticatorUseCaseAuthenticationService
    private var isUnlocked = true

    public func receiveAuthenticationSuccess() {
        isUnlocked = true
        output.shouldUnlock()
    }

    public func unlock() {
        guard !isUnlocked else { return }
        authenticationService.startAuthentication()
    }

    public func lock() {
        guard isUnlocked else { return }
        isUnlocked = false
        output.shouldLock()
    }

    public init(output: OverlayAuthenticatorUseCaseOutput, authenticationService: OverlayAuthenticatorUseCaseAuthenticationService) {
        self.output = output
        self.authenticationService = authenticationService
    }
}
