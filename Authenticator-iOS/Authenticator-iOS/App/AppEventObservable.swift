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
    private var _observers: [WeakBox<AnyObject>] = []

    var observers: [AppEventObserver] {
        _observers.removeAll(where: { $0.item == nil })
        return _observers.compactMap { $0.item as? AppEventObserver }
    }

    init() {
        notificationCenter.addObserver(self, selector: #selector(appDidEnterForeground), name: UIScene.didActivateNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(appWillEnterBackground), name: UIScene.willDeactivateNotification, object: nil)
    }

    deinit {
        notificationCenter.removeObserver(self)
    }

    func observeWeakly(_ observer: AppEventObserver) {
        _observers.append(WeakBox(observer))
    }

    @objc
    func appDidEnterForeground() {
        observers.forEach {
            $0.handle(event: .appDidEnterForeground)
        }
    }

    @objc
    func appWillEnterBackground() {
        observers.forEach {
            $0.handle(event: .appWillEnterBackground)
        }
    }
}
