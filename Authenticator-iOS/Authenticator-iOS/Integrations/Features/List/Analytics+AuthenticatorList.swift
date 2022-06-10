//
//  Analytics+List.swift
//  Authenticator-iOS
//
//  Created by Kertész Jenő Ármin on 2022. 05. 16..
//

import Combine
import Resolver

extension AnyPublisher where Output == ListEvent {
    func trackListEvents(analytics: AuthenticatorAnalytics = Resolver.resolve()) -> AnyPublisher<Output, Failure> {
        return self.handleEvents(receiveOutput: { event in
            switch event {
            case .viewDidLoad:
                analytics.track(name: "List Opened")
            case .addAccountDidPress:
                analytics.track(name: "Add new account did press")
            default:
                break
            }
        })
        .eraseToAnyPublisher()
    }
}
