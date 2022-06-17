//
//  EditAccountFlow.swift
//  Authenticator-iOS
//
//  Created by Kertész Jenő Ármin on 2022. 06. 06..
//

import UIKit
import AuthenticatorListBusiness

class EditAccountFlow {
    func start(context: EditAccountContext, source: UIViewController?) {
        guard let source = source else { return }

        let alert = UIAlertController(title: "Edit account".localized, message: "", preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "Issuer".localized
            textField.text = context.item.issuer
        }
        alert.addTextField { textField in
            textField.placeholder = "Username".localized
            textField.text = context.item.username
        }
        alert.addAction(.init(title: "Cancel".localized, style: .cancel, handler: nil))
        alert.addAction(.init(title: "Finish".localized, style: .default, handler: { _ in
            context.callback(alert.textFields?.first?.text, alert.textFields?.last?.text)
        }))
        onMain {
            source.present(alert, animated: true)
        }
    }
}
