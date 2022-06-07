//
//  Clock.swift
//  Authenticator-iOS
//
//  Created by Kertész Jenő Ármin on 2022. 04. 24..
//

import Combine

public final class Clock {
    private var clockCancellable: AnyCancellable?
    private let clockSubject = CurrentValueSubject<Date, Never>(Date())
    public var clockPublisher: AnyPublisher<Date, Never> {
        clockSubject.eraseToAnyPublisher()
    }

    public init(timeInterval: TimeInterval = 1) {
        clockCancellable = Timer
            .publish(every: timeInterval, on: RunLoop.main, in: .common)
            .autoconnect()
            .subscribe(clockSubject)
    }
}
