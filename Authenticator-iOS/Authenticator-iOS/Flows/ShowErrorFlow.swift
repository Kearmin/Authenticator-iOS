//
//  ShowErrorFlow.swift
//  Authenticator-iOS
//
//  Created by Kertész Jenő Ármin on 2022. 06. 06..
//

import UIKit

enum ShowErrorFlow {
    static func start(with source: UIViewController?, title: String, message: String, okAction: (() -> Void)? = nil) {
        guard let source = source else { return }
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert)
        alert.addAction(.init(title: "Ok".localized, style: .default, handler: { _ in
            okAction?()
        }))
        onMain {
            source.present(alert, animated: true, completion: nil)
        }
    }
}
