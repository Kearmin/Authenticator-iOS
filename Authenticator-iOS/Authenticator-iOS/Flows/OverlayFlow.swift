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
    private var appWindow: UIWindow?
    private var overlayWindow: UIWindow?
    private var overlayEventCancellable: AnyCancellable?
    private weak var sceneDelegate: SceneDelegate?
    private let overlayFactory: OverlayFactory

    init(overlayFactory: @escaping OverlayFactory) {
        self.overlayFactory = overlayFactory
    }

    func start(with windowScene: UIWindowScene, appWindow: UIWindow?, sceneDelegate: SceneDelegate) {
        self.overlayWindow = makeOverlayWindow(with: windowScene)
        self.sceneDelegate = sceneDelegate
        self.appWindow = appWindow
        sceneDelegate.window = overlayWindow
        sceneDelegate.window?.makeKeyAndVisible()
    }
}

private extension OverlayFlow {
    func makeOverlayWindow(with windowScene: UIWindowScene) -> UIWindow {
        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = makeOverlayViewController()
        return window
    }

    func makeOverlayViewController() -> OverlayViewController {
        let (viewController, eventSubject) = overlayFactory()
        overlayEventCancellable = eventSubject
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
        sceneDelegate?.window = toWindow
        toWindow.makeKeyAndVisible()
        fromWindow.isHidden = true
    }
}
