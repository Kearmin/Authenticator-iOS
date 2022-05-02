//
//  Navigator.swift
//  Authenticator-iOS
//
//  Created by Kertész Jenő Ármin on 2022. 04. 23..
//

import UIKit

public final class UIKitNavigator {
    public init () { }
}

public extension UIKitNavigator {
    func showRootViewControllerEmbeddedInNavigationController(on window: UIWindow, rootViewController: UIViewController) {
        let navController = UINavigationController(rootViewController: rootViewController)
        showRootViewController(on: window, rootViewController: navController)
    }

    func showRootViewController(on window: UIWindow, rootViewController: UIViewController) {
        onMain {
            window.rootViewController = rootViewController
            window.makeKeyAndVisible()
        }
    }

    func presentFullScreenEmbeddedInNavigationController(view: UIViewController, source: UIViewController) {
        let navigationController = UINavigationController(rootViewController: view)
        presentFullScreen(view: navigationController, source: source)
    }

    func presentFullScreen(view: UIViewController, source: UIViewController) {
        view.modalPresentationStyle = .fullScreen
        onMain {
            source.present(view, animated: true)
        }
    }

    func presentSimpleAlert(
        title: String,
        message: String,
        source: UIViewController,
        handler: ((UIAlertAction) -> Void)? = nil) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: handler))
        onMain {
            source.present(alert, animated: true)
        }
    }

    func dismiss(viewController: UIViewController, animated: Bool = true) {
        onMain {
            viewController.dismiss(animated: animated)
        }
    }
}

private extension UIKitNavigator {
    private func onMain(_ block: @escaping () -> Void) {
        if Thread.isMainThread {
            block()
        } else {
            DispatchQueue.main.async {
                block()
            }
        }
    }
}
