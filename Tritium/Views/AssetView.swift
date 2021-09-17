//
//  AssetView.swift
//  AssetView
//
//  Created by Alexander Cyon on 2021-09-17.
//

import Foundation
import SwiftUI
import Guld

struct AssetView: View {
    let loadedAsset: LoadedAsset
    
    var body: some View {
        Text("\(loadedAsset.fileName)")
    }
}
