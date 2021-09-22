//
//  MapView.swift
//  Tritium
//
//  Created by Alexander Cyon on 2021-09-22.
//

import SwiftUI
import Combine
import Makt

struct MapView: View {
    let mapID: Map.ID
    
    var body: some View {
        Button("Parse map: \(mapID.fileName)") {
            print("should parse map: \(mapID.fileName)")
        }
    }
}
