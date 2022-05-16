//
//  AppOverlayManager.swift
//  Authenticator-iOS
//
//  Created by Kertész Jenő Ármin on 2022. 05. 16..
//

import Foundation
import UIKit
import Combine

class AppOverLayManager {
    let originalWindow: UIWindow
    let overLayWindow: UIWindow
    let sceneDelegate: SceneDelegate
    var subscriptions = Set<AnyCancellable>()

    init(with windowScene: UIWindowScene, originalWindow: UIWindow, sceneDelegate: SceneDelegate) {
        self.originalWindow = originalWindow
        self.sceneDelegate = sceneDelegate
        overLayWindow = UIWindow(windowScene: windowScene)
        overLayWindow.rootViewController = OverlayViewController()
        NotificationCenter.default
            .publisher(for: UIApplication.willResignActiveNotification)
            .sink(receiveValue: appMovedToBackground(_:))
            .store(in: &subscriptions)
        NotificationCenter.default
            .publisher(for: UIApplication.didBecomeActiveNotification)
            .sink(receiveValue: appEnteredForeground(_:))
            .store(in: &subscriptions)
    }

    func appMovedToBackground(_ notification: Notification) {
        switchWindow(from: originalWindow, to: overLayWindow)
    }

    func appEnteredForeground(_ notification: Notification) {
        switchWindow(from: overLayWindow, to: originalWindow)
    }

    private func switchWindow(from fromWindow: UIWindow, to toWindow: UIWindow) {
        onMain {
            self.sceneDelegate.window = toWindow
            toWindow.makeKeyAndVisible()
            fromWindow.isHidden = true
        }
    }
}
