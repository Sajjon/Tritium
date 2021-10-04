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
    let onTap: () -> Void
}

extension TileView {
    
    @ViewBuilder
    var body: some View {
        ZStack {
            ForEach(tile.images) { image in
                Image(decorative: image.cgImage, scale: 1.0)
            }
        }
        .frame(width: 32, height: 32)
        .onTapGesture(perform: onTap)
    }
    
}

struct RenderMapView: View {
    @ObservedObject var model: Model
    @State private var debugTile: ProcessedMap.Tile? = nil
    
    var body: some View {
        ZStack {
            terrainView
            objectsView
        }
    }
    
    var terrainView: some View {
        LazyVGrid(
            columns: model.columns,
            alignment: .center,
            spacing: 0
        ) {
            ForEach(model.tiles) { tile in
                TileView(tile: tile) {
                    debugTile = tile
                }
            }
        }
        .sheet(isPresented: .constant(debugTile != nil)) {
            DebugTileView(tile: debugTile!) {
                debugTile = nil
            }
        }
    }
    
    var objectsView: some View {
        ForEach(model.objects) { object in
            Image(
                decorative: object.image.cgImage,
                scale: 1.0
            )
                .frame(
                    width: CGFloat(object.width) * Model.tileSize,
                    height: CGFloat(object.height) * Model.tileSize
                ).position(
                    x: CGFloat(object.origin.x) * Model.tileSize,
                    y: CGFloat(object.origin.y) * Model.tileSize
                )
        }
    }
}

// MARK: Model
extension RenderMapView {
    final class Model: ObservableObject {
        static let tileSize: CGFloat = 32
        @Published var columns: [GridItem]
        
        @Published var tiles: [ProcessedMap.Tile]
        @Published var objects: [ProcessedMap.Object]
        
        private let processedMap: ProcessedMap
        fileprivate let assets: Assets
        
        init(processedMap: ProcessedMap, assets: Assets) {
            self.processedMap = processedMap
            self.assets = assets
            
            columns = .init(
                repeating: .init(
                    .flexible(minimum: Model.tileSize, maximum: Model.tileSize),
                    spacing: 0,
                    alignment: .center
                ),
                count: processedMap.width
            )
            
            tiles = processedMap.aboveGround.tiles
            objects = processedMap.aboveGround.objects
            
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


// MARK: ProcessedMap.Object + Identifiable
extension ProcessedMap.Object: Identifiable {
    public typealias ID = Map.Object
    public var id: ID { self.mapObject }
}


