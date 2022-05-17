//
//  OverLayView.swift
//  OverlayView
//
//  Created by Kertész Jenő Ármin on 2022. 05. 17..
//

import SwiftUI

public struct OverlayView: View {
    @State public var imageName: String = ""
    @State public var bunlde: Bundle = .main

    public init(imageName: String = "") {
        self.imageName = imageName
    }

    public var body: some View {
            Image(imageName, bundle: bunlde)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .padding()
    }
}

struct OverLayView_Previews: PreviewProvider {
    static var previews: some View {
        OverlayView(imageName: "ZyzzSticker")
    }
}
