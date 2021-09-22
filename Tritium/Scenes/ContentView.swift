//
//  ContentView.swift
//  ContentView
//
//  Created by Alexander Cyon on 2021-09-17.
//

import Foundation
import Malm
import SwiftUI

struct ContentView: View {
    @State var config: Config?
    
    var body: some View {
        NavigationView {
            if let config = config {
                VStack {
                    NavigationLink("Assets", destination: GameFilesView(config: config))
                    NavigationLink("Maps", destination: MapListView(config: config))
                }
            } else {
                ConfigView(config: $config)
            }
        }
        .font(.largeTitle)
        .frame(width: 2048, height: 1024)
    }
}
