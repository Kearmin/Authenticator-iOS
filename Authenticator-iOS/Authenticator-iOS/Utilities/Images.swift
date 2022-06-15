//
//  Images.swift
//  Authenticator-iOS
//
//  Created by Kertész Jenő Ármin on 2022. 05. 16..
//

import Foundation
import UIKit

enum Images: String, CaseIterable {
    case zyzzSticker = "ZyzzSticker"

    var image: UIImage? {
        switch self {
        case .zyzzSticker:
            return UIImage(named: self.rawValue)
        }
    }
}
