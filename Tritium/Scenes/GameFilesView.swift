//
//  GameFilesView.swift
//  GameFilesView
//
//  Created by Alexander Cyon on 2021-09-17.
//

import SwiftUI
import Malm

struct GameFilesView: View {
    let config: Config
    
    var body: some View {
        Text("Resource data: \(config.gamesFilesDirectories.data)")
    }
}

