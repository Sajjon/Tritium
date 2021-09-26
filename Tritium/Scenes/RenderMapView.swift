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
//    final class Model: ObservableObject {
//
//        private let tile: ProcessedMap.Tile
//        private let assets: Assets
//
//        let terrainSurfaceImage: LoadedImage
//
//
//        init(
//            tile: ProcessedMap.Tile,
//            terrainSurfaceImage: LoadedImage,
//        ) {
//            self.tile = tile
//        }
//
//    }
//
//    @ObservedObject var model: Model
}

extension TileView {
    
    @ViewBuilder
    var body: some View {
        Image(decorative: tile.surfaceImage.image, scale: 1.0).frame(width: 32, height: 32)
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


