//
//  OverlayComposer.swift
//  Authenticator-iOS
//
//  Created by Kertész Jenő Ármin on 2022. 05. 17..
//

import Foundation
import OverlayView
import OverlayBusiness

import LocalAuthentication
import Combine
import UIKit

enum OverlayComposer {
    static func overlay() -> (OverlayViewController, OverlayEventPublisher) {
        let eventSubject = PassthroughSubject<OverlayEvent, Never>()
        let serviceAdapter = OverlayAuthenticatorUseCaseAuthenticationServiceAdapter()
        let outputAdapter = OverlayAuthenticatorUseCaseOutputAdapter(eventSubject: eventSubject)
        let useCase = OverlayAuthenticatorUseCase(
            output: outputAdapter,
            authenticationService: serviceAdapter)
        serviceAdapter.usecase = useCase
        let view = OverlayView(imageName: Images.zyzzSticker.rawValue) {
            serviceAdapter.unlock()
        }
        let viewController = OverlayViewController.init(rootView: view)
        viewController.onViewDidLoad = {
            Queues.generalBackgroundQueue.async {
                useCase.lock()
            }
        }

        return (viewController, eventSubject.eraseToAnyPublisher())
    }
}
