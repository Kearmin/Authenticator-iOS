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

typealias OverlayFactory = () -> (OverlayViewController, OverlayEventPublisher)

enum OverlayComposer {
    struct Dependencies {
        let willResignActivePublisher: AnyPublisher<Void, Never>
        let didBecomeActivePublisher: AnyPublisher<Void, Never>
        let authentication: () -> AnyPublisher<Bool, Error>
        let analytics: AuthenticatorAnalytics
    }
    static func overlay(dependencies: Dependencies) -> (OverlayViewController, OverlayEventPublisher) {
        let eventSubject = PassthroughSubject<OverlayEvent, Never>()
        let serviceAdapter = OverlayAuthenticatorUseCaseAuthenticationServiceAdapter(
            willResignActivePublisher: dependencies.willResignActivePublisher,
            didBecomeActivePublisher: dependencies.didBecomeActivePublisher,
            authentication: dependencies.authentication)
        let outputAdapter = OverlayAuthenticatorUseCaseOutputAdapter(eventSubject: eventSubject)
        let useCase = OverlayAuthenticatorUseCase(
            output: outputAdapter,
            authenticationService: serviceAdapter)
        serviceAdapter.usecase = useCase
        let view = OverlayView(imageName: Images.zyzzSticker.rawValue, configuration: .init(unlockText: "Unlock".localized)) {
            serviceAdapter.unlock()
        }
        let viewController = OverlayViewController.init(rootView: view)
        viewController.onViewDidLoad = {
            useCase.lock()
        }
        let trackedEventPublisher = eventSubject.eraseToAnyPublisher().trackOverlayEvents(analytics: dependencies.analytics)
        return (viewController, trackedEventPublisher)
    }
}
