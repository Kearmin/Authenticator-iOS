//
//  Resolver+Overlay.swift
//  Authenticator-iOS
//
//  Created by Kertész Jenő Ármin on 2022. 06. 12..
//

import Foundation
import Resolver

extension Resolver {
    static func registerOverlayDependencies() {
        register(OverlayComposer.Dependencies.self) { resolver in
            let appEventPublishers: AppEventPublishers = resolver.resolve()
            let biometricAuthenticator: BiometricAuthenticator = resolver.resolve()
            return OverlayComposer.Dependencies(
                willResignActivePublisher: appEventPublishers.willResignActivePublisher,
                didBecomeActivePublisher: appEventPublishers.didBecomeActivePublisher,
                authentication: biometricAuthenticator.biometricAuthentication,
                analytics: resolver.resolve())
        }

        register(OverlayFactory.self) { resolver in
            { OverlayComposer.overlay(dependencies: resolver.resolve()) }
        }
    }
}
