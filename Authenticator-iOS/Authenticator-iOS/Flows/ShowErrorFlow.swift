//
//  ShowErrorFlow.swift
//  Authenticator-iOS
//
//  Created by Kertész Jenő Ármin on 2022. 06. 06..
//

import UIKit

class ShowErrorFlow {
    let source: UIViewController?
    let title: String
    let message: String

    init(source: UIViewController?, title: String, message: String) {
        self.source = source
        self.title = title
        self.message = message
    }

    func start() {
        guard let source = source else { return }
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert)
        onMain {
            source.present(alert, animated: true, completion: nil)
        }
    }
}
