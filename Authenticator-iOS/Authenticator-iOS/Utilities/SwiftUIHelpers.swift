//
//  SwiftUIHelpers.swift
//  Authenticator-iOS
//
//  Created by Kertész Jenő Ármin on 2022. 05. 15..
//

import Foundation
import SwiftUI

func onMainWithAnimation(_ block: @escaping () -> Void) {
    onMain {
        withAnimation {
            block()
        }
    }
}

func onMainWithAnimation(_ animation: Animation, _ block: @escaping () -> Void) {
    onMain {
        withAnimation(animation) {
            block()
        }
    }
}
