//
//  AppEvent.swift
//  Authenticator-iOS
//
//  Created by Kertész Jenő Ármin on 2022. 05. 15..
//

import Combine

enum AppEvent {
    case newAccountAdded
}

extension AnyPublisher where Output == AppEvent, Failure == Never {
    func filter(_ event: AppEvent) -> AnyPublisher<Void, Failure> {
        self.filter { $0 == event }
            .map { _ in () }
            .eraseToAnyPublisher()
    }
}
