//
//  AppEventObservable.swift
//  Authenticator-iOS
//
//  Created by Kertész Jenő Ármin on 2022. 04. 24..
//

import Foundation
import UIKit

enum AppEvent {
    case appDidEnterForeground
    case appWillEnterBackground
}

protocol AppEventObserver: AnyObject {
    func handle(event: AppEvent)
}

final class AppEventObservable {
    private let notificationCenter = NotificationCenter.default
    private var observers: [AppEventObserver] = []

    init() {
        notificationCenter.addObserver(self, selector: #selector(appDidEnterForeground), name: UIScene.didActivateNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(appWillEnterBackground), name: UIScene.willDeactivateNotification, object: nil)
    }

    deinit {
        notificationCenter.removeObserver(self)
    }

    func observe(_ observer: AppEventObserver) {
        observers.append(observer)
    }

    func removeObserver(_ observer: AppEventObserver) {
        observers.removeAll(where: { $0 === observer })
    }

    @objc
    private func appDidEnterForeground() {
        observers.forEach {
            $0.handle(event: .appDidEnterForeground)
        }
    }

    @objc
    private func appWillEnterBackground() {
        observers.forEach {
            $0.handle(event: .appWillEnterBackground)
        }
    }
}
