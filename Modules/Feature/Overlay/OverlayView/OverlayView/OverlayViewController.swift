//
//  OverlayViewController.swift
//  OverlayView
//
//  Created by Kertész Jenő Ármin on 2022. 05. 17..
//

import SwiftUI

public final class OverlayViewController: UIHostingController<OverlayView> {
    public var onViewDidLoad: (() -> Void)?

    public override func viewDidLoad() {
        super.viewDidLoad()
        onViewDidLoad?()
    }
}
