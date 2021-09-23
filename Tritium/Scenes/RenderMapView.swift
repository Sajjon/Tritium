//
//  RenderMapView.swift
//  Tritium
//
//  Created by Alexander Cyon on 2021-09-23.
//

import SwiftUI
import Combine
import Makt

struct TileView: View {
    let tile: ProcessedMap.Tile
    var body: some View {
        Text(tile.emojiString)
            .font(.system(.footnote))
    }
}


struct RenderMapView: View {
    @ObservedObject var model: Model
    
    var body: some View {
        LazyVGrid(
            columns: model.columns,
            alignment: .center,
            spacing: 0
        ) {
            ForEach(model.tiles) { tile in
                TileView(tile: tile)
            }
        }
    }
}

// MARK: Model
extension RenderMapView {
    final class Model: ObservableObject {
        @Published var columns: [GridItem]
        
        var tiles: [ProcessedMap.Tile] {
            processedMap.aboveGroundTiles
        }
        
        private let processedMap: ProcessedMap
        
        init(processedMap: ProcessedMap) {
            self.processedMap = processedMap
            
            columns = .init(
                repeating: .init(
                    .fixed(10),
                    spacing: 0,
                    alignment: .center
                ),
                count: processedMap.width
            )
            
        }
    }
}

extension RenderMapView {
    init(processedMap: ProcessedMap) {
        self.init(model: .init(processedMap: processedMap))
    }
}

// MARK: ProcessedMap.Tile + Identifiable
extension ProcessedMap.Tile: Identifiable {
    public typealias ID = Position
    public var id: ID { position }
}


