//
//  DeleteAccountFlow.swift
//  Authenticator-iOS
//
//  Created by Kertész Jenő Ármin on 2022. 06. 06..
//

import UIKit

class DeleteAccountFlow {
    func start(context: DeleteAccountContext, source: UIViewController?) {
        guard let source = source else { return }
        let alert = UIAlertController(
            title: "Confirm".localized,
            message: "Do you really want to delete this account?".localized,
            preferredStyle: .alert)
        alert.addAction(.init(title: "Cancel".localized, style: .cancel, handler: nil))
        alert.addAction(.init(title: "Delete".localized, style: .destructive, handler: { _ in
            context.callback()
        }))
        onMain {
            source.present(alert, animated: true)
        }
    }
}
