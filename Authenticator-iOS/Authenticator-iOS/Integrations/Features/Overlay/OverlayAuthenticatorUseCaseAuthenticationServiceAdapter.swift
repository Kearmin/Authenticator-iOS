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
            .receive(on: Queues.generalBackgroundQueue)
            .sink { [weak self] _ in
                self?.usecase?.lock()
            }
            .store(in: &subscriptions)

        notificationCenter
            .publisher(for: UIApplication.didBecomeActiveNotification)
            .receive(on: Queues.generalBackgroundQueue)
            .sink { [weak self] _ in
                self?.unlock()
            }
            .store(in: &subscriptions)
    }

    var skipnext = false

    func unlock() {
        if !self.skipnext {
            self.usecase?.unlock()
        } else {
            self.skipnext.toggle()
        }
    }

    func startAuthentication() {
        let context = LAContext()
        context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: "Unlock your accounts") { success, _ in
            if success {
                self.usecase?.receiveAuthenticationSuccess()
            } else {
                self.skipnext = true
            }
        }
    }
}
