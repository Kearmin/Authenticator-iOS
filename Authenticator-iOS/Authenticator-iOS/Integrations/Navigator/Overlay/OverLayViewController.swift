//
//  OverLayViewController.swift
//  Authenticator-iOS
//
//  Created by Kertész Jenő Ármin on 2022. 04. 24..
//

import Foundation
import UIKit

final class OverLayViewController: UIViewController {
    private let blueView: UIVisualEffectView = {
        let blurEffectView = UIVisualEffectView()
        blurEffectView.backgroundColor = .clear
        blurEffectView.effect = UIBlurEffect(style: .systemUltraThinMaterial)
        return blurEffectView
    }()

    override func loadView() {
        view = blueView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
    }
}
