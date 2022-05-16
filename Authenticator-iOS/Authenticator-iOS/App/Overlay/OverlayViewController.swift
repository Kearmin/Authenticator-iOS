//
//  OverlayViewController.swift
//  Authenticator-iOS
//
//  Created by Kertész Jenő Ármin on 2022. 05. 16..
//

import UIKit

class OverlayViewController: UIViewController {
    let imageView = UIImageView(image: Images.zyzzSticker.image)

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(imageView)
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemBackground
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -45),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10)
        ])
    }
}
