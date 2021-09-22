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
    enum ViewSelection {
        case archiveList
        case mapList
    }
    
    @State var config: Config?
    @State var selection: ViewSelection = .mapList
    
    var body: some View {
//        Group {
            if let config = config {
                VStack {
                    Picker("Open asset class", selection: $selection) {
                        Text("Maps").tag(ViewSelection.mapList)
                        Text("Archives").tag(ViewSelection.archiveList)
                    }.pickerStyle(SegmentedPickerStyle()).frame(minHeight: 60)
                    
                    Group {
                        
                    switch selection {
                    case .archiveList:
                        GameFilesView(config: config)
                    case .mapList:
                        MapListView(config: config)
                    }
                    }.padding()
                }
           
            } else {
                ConfigView(config: $config)
            }
//        .font(.largeTitle)

    }
}
