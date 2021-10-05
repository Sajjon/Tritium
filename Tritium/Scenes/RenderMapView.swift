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
        .frame(width: .pixelsPerTile, height: .pixelsPerTile)
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
        .fixedSize(horizontal: true, vertical: true)
        .frame(width: model.width, height: model.height)
        .padding()
    }
    
    var terrainView: some View {
        LazyVGrid(
            columns: model.columns,
            alignment: .leading,
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
        ZStack {
            ForEach(model.objects) { object in
                Image(
                    decorative: object.image.cgImage,
                    scale: 1.0
                )
                    .frame(width: CGFloat(object.image.width), height: CGFloat(object.image.height))
                    .position(
                        x: ((CGFloat(object.position.x + 1) * .pixelsPerTile) - CGFloat(object.image.width)/2),
                        y: ((CGFloat(object.position.y + 1) * .pixelsPerTile) - CGFloat(object.image.height)/2)
                    )
            }
        }   .clipped()
    }
}

// MARK: Model
extension RenderMapView {
    final class Model: ObservableObject {

        @Published var columns: [GridItem]
        
        @Published var tiles: [ProcessedMap.Tile]
        @Published var objects: [ProcessedMap.Object]
        
        private let processedMap: ProcessedMap
        var width: CGFloat { CGFloat(processedMap.size.width) * .pixelsPerTile }
        var height: CGFloat { CGFloat(processedMap.size.height) * .pixelsPerTile }
        fileprivate let assets: Assets
        
        init(processedMap: ProcessedMap, assets: Assets) {
            self.processedMap = processedMap
            self.assets = assets
            
            columns = .init(
                repeating: .init(
                    .fixed(CGFloat.pixelsPerTile),
                    spacing: 0,
                    alignment: .topLeading
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


