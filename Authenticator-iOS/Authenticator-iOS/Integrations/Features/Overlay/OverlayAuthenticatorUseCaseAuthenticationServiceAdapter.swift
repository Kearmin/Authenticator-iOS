//
//  OverlayAuthenticatorUseCaseAuthenticationServiceAdapter.swift
//  Authenticator-iOS
//
//  Created by Kertész Jenő Ármin on 2022. 05. 18..
//

import UIKit
import OverlayBusiness
import Combine
import LocalAuthentication

class OverlayAuthenticatorUseCaseAuthenticationServiceAdapter: OverlayAuthenticatorUseCaseAuthenticationService {
    var usecase: OverlayAuthenticatorUseCase?
    private let authentication: () -> AnyPublisher<Bool, Error>
    private var subscriptions = Set<AnyCancellable>()

    init(
        willResignActivePublisher: AnyPublisher<Void, Never>,
        didBecomeActivePublisher: AnyPublisher<Void, Never>,
        authentication: @escaping () -> AnyPublisher<Bool, Error>
    ) {
        self.authentication = authentication
        willResignActivePublisher
            .sink { [weak self] in
                self?.usecase?.lock()
            }
            .store(in: &subscriptions)

        didBecomeActivePublisher
            .sink { [weak self] in
                self?.unlock()
            }
            .store(in: &subscriptions)
    }

    // If Authentication fails, that triggers DidBecomeActive and causes an authentication loop
    // skipping the next event breaks the cycle
    var skipnext = false

    func unlock() {
        if self.skipnext {
            self.skipnext = false
        } else {
            self.usecase?.unlock()
        }
    }

    func startAuthentication() {
        authentication()
            .sink { _ in
            } receiveValue: { success in
                if success {
                    self.usecase?.receiveAuthenticationSuccess()
                } else {
                    self.skipnext = true
                }
            }
            .store(in: &subscriptions)
    }
}
