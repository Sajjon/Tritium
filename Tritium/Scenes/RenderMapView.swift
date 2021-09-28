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
}

extension TileView {
    
    @ViewBuilder
    var body: some View {
        ZStack {
            Image(decorative: tile.surfaceImage.image.cgImage, scale: 1.0).frame(width: 32, height: 32)
            Text("\(tile.terrain.mirroring.flipVertical == true ? "v" : "")\(tile.terrain.mirroring.flipHorizontal == true ? "h" : "")")
        }.onTapGesture {
            print(tile)
        }
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
                TileView.init(tile: tile)
            }
        }.frame(width: 1152, height: 1152)
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
        fileprivate let assets: Assets
        
        init(processedMap: ProcessedMap, assets: Assets) {
            self.processedMap = processedMap
            self.assets = assets
            
            columns = .init(
                repeating: .init(
                    .flexible(minimum: 32, maximum: 32),
                    spacing: 0,
                    alignment: .center
                ),
                count: processedMap.width
            )
            
        }
    }
}

extension RenderMapView {
    init(processedMap: ProcessedMap, assets: Assets) {
        self.init(model: .init(processedMap: processedMap, assets: assets))
    }
}

// MARK: ProcessedMap.Tile + Identifiable
extension ProcessedMap.Tile: Identifiable {
    public typealias ID = Position
    public var id: ID { position }
}


