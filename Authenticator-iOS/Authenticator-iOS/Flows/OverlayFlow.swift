//
//  OverlayFlow.swift
//  Authenticator-iOS
//
//  Created by Kertész Jenő Ármin on 2022. 06. 06..
//

import Foundation
import OverlayView
import UIKit
import Combine
import Resolver


class OverlayFlow {
    private let sceneDelegate: SceneDelegate
    private let appWindow: UIWindow?
    private var overlayWindow: UIWindow?
    private var overlayEventCancellable: AnyCancellable?

    init(appWindow: UIWindow?, sceneDelegate: SceneDelegate) {
        self.appWindow = appWindow
        self.sceneDelegate = sceneDelegate
    }

    func start(with windowScene: UIWindowScene) {
        self.overlayWindow = makeOverlayWindow(with: windowScene)
        sceneDelegate.window = overlayWindow
        sceneDelegate.window?.makeKeyAndVisible()
    }

    func makeOverlayWindow(with windowScene: UIWindowScene) -> UIWindow {
        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = makeOverlayViewController()
        return window
    }

    func makeOverlayViewController() -> OverlayViewController {
        let (viewController, eventSubject) = OverlayComposer.overlay(analytics: Resolver.resolve())
        overlayEventCancellable = eventSubject
            .trackOverlayEvents()
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: handleOverlayEvent(_:))
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
        sceneDelegate.window = toWindow
        toWindow.makeKeyAndVisible()
        fromWindow.isHidden = true
    }
}
