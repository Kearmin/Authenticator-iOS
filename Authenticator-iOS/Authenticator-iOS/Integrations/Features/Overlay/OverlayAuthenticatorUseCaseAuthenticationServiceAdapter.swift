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
    var subscriptions = Set<AnyCancellable>()

    init() {
        let notificationCenter = NotificationCenter.default
        notificationCenter
            .publisher(for: UIApplication.willResignActiveNotification)
            .sink { [weak self] _ in
                self?.usecase?.lock()
            }
            .store(in: &subscriptions)

        notificationCenter
            .publisher(for: UIApplication.didBecomeActiveNotification)
            .sink { [weak self] _ in
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
        let context = LAContext()
        context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: "Unlock your accounts".localized) { success, _ in
            if success {
                self.usecase?.receiveAuthenticationSuccess()
            } else {
                self.skipnext = true
            }
        }
    }
}
