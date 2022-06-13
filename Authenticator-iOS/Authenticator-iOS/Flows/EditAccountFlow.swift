//
//  EditAccountFlow.swift
//  Authenticator-iOS
//
//  Created by Kertész Jenő Ármin on 2022. 06. 06..
//

import UIKit
import AuthenticatorListBusiness

enum EditAccountFlow {
    static func start(account: AuthenticatorListRowContent, source: UIViewController?, didFinishUpdate: @escaping (_ issuer: String?, _ username: String?) -> Void) {
        guard let source = source else { return }

        let alert = UIAlertController(title: "Edit account".localized, message: "", preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "Issuer".localized
            textField.text = account.issuer
        }
        alert.addTextField { textField in
            textField.placeholder = "Username".localized
            textField.text = account.username
        }
        alert.addAction(.init(title: "Cancel".localized, style: .cancel, handler: nil))
        alert.addAction(.init(title: "Finish".localized, style: .default, handler: { _ in
            didFinishUpdate(alert.textFields?.first?.text, alert.textFields?.last?.text)
        }))
        onMain {
            source.present(alert, animated: true)
        }
    }
}
