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
        Group {
            if let config = config {
                GameFilesView(config: config)
            } else {
                ConfigView(config: $config)
            }
        }
        .font(.largeTitle)
        .frame(width: 1024, height: 512)
    }
}
