//
//  AppEvent.swift
//  Authenticator-iOS
//
//  Created by Kertész Jenő Ármin on 2022. 05. 15..
//

import Combine

typealias AppEventSubject = PassthroughSubject<AppEvent, Never>
typealias AppEventPublisher = AnyPublisher<AppEvent, Never>

enum AppEvent {
    case newAccountCreated
}

extension AnyPublisher where Output == AppEvent, Failure == Never {
    func filter(_ event: AppEvent) -> AnyPublisher<Void, Failure> {
        self.filter { $0 == event }
            .map { _ in () }
            .eraseToAnyPublisher()
    }
}
