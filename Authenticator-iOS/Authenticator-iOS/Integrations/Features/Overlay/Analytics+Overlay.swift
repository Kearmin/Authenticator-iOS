//
//  Analytics+Overlay.swift
//  Authenticator-iOS
//
//  Created by Kertész Jenő Ármin on 2022. 05. 18..
//

import Combine
import Resolver

extension AnyPublisher where Output == OverlayEvent {
    func trackOverlayEvents() -> AnyPublisher<Output, Failure> {
        handleEvents(receiveOutput: { event in
            let analytics: AuthenticatorAnalytics = Resolver.resolve()
            switch event {
            case .lock:
                analytics.track(name: "App lock overlay appeared")
            case .unlock:
                analytics.track(name: "App lock overlay disappeared")
            }
        })
        .eraseToAnyPublisher()
    }
}
