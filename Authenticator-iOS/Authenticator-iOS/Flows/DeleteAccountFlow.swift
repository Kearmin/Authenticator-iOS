//
//  DeleteAccountFlow.swift
//  Authenticator-iOS
//
//  Created by Kertész Jenő Ármin on 2022. 06. 06..
//

import UIKit

enum DeleteAccountFlow {
    static func start(source: UIViewController?, didPressDelete: @escaping () -> Void) {
        guard let source = source else { return }
        let alert = UIAlertController(
            title: "Confirm".localized,
            message: "Do you really want to delete this account?".localized,
            preferredStyle: .alert)
        alert.addAction(.init(title: "Cancel".localized, style: .cancel, handler: nil))
        alert.addAction(.init(title: "Delete".localized, style: .destructive, handler: { _ in
            didPressDelete()
        }))
        onMain {
            source.present(alert, animated: true)
        }
    }
}
