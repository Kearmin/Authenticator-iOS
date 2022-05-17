//
//  SceneDelegate+Overlay.swift
//  Authenticator-iOS
//
//  Created by Kertész Jenő Ármin on 2022. 05. 18..
//

import Foundation
import UIKit
import OverlayBusiness
import OverlayView
import Combine

extension SceneDelegate {
    func makeOverlayWindow(with windowScene: UIWindowScene) -> UIWindow {
        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = makeOverlayViewController()
        return window
    }

    func makeOverlayViewController() -> OverlayViewController {
        let (viewController, eventSubject) = OverlayComposer.overlay()
        eventSubject
            .trackOverlayEvents()
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: handleOverlayEvent(_:))
            .store(in: &subscriptions)
        return viewController
    }

    func handleOverlayEvent(_ event: OverlayEvent) {
        guard let appWindow = self.appWindow, let overlayWindow = self.overlayWindow else {
            return
        }

        switch event {
        case .lock:
            self.switchWindow(from: appWindow, to: overlayWindow)
        case .unlock:
            self.switchWindow(from: overlayWindow, to: appWindow)
        }
    }

    func switchWindow(from fromWindow: UIWindow, to toWindow: UIWindow) {
        window = toWindow
        toWindow.makeKeyAndVisible()
        fromWindow.isHidden = true
    }
}
