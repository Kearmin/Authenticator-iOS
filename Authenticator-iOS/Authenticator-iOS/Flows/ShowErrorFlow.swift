//
//  ShowErrorFlow.swift
//  Authenticator-iOS
//
//  Created by Kertész Jenő Ármin on 2022. 06. 06..
//

import UIKit

class ShowErrorFlow {
    func start(context: ErrorContext, source: UIViewController?) {
        guard let source = source else { return }
        let alert = UIAlertController(
            title: context.title,
            message: context.message,
            preferredStyle: .alert)
        alert.addAction(.init(title: "Ok".localized, style: .default, handler: { _ in
            context.okAction?()
        }))
        onMain {
            source.present(alert, animated: true, completion: nil)
        }
    }
}
