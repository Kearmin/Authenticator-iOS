//
//  AppEventPublishers.swift
//  Authenticator-iOS
//
//  Created by Kertész Jenő Ármin on 2022. 06. 12..
//

import Combine
import UIKit

class AppEventPublishers {
    let notificationCenter: NotificationCenter

    init(notificationCenter: NotificationCenter) {
        self.notificationCenter = notificationCenter
    }

    var willResignActivePublisher: AnyPublisher<Void, Never> {
        notificationCenter
            .publisher(for: UIApplication.willResignActiveNotification)
            .map { _ in () }
            .eraseToAnyPublisher()
    }

    var didBecomeActivePublisher: AnyPublisher<Void, Never> {
        notificationCenter
            .publisher(for: UIApplication.didBecomeActiveNotification)
            .map { _ in () }
            .eraseToAnyPublisher()
    }
}
