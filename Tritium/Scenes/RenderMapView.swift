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
    
    final class Model: ObservableObject {
        
        private let tile: ProcessedMap.Tile
        private let assets: Assets

        @Published var terrainImageState: LoadingState<CGImage> = .idle
        
        private var cancellables = Set<AnyCancellable>()
        
        func loadTerrainImage() {
            terrainImageState = .loading(progress: nil)
            assets
                .loadImage(terrain: tile.terrain)
                .receive(on: RunLoop.main)
                .sink(
                    receiveValue: { [self] terrainImage in
                        terrainImageState = .loaded(terrainImage)
                    }
                ).store(in: &cancellables)
        }
        
        init(
            tile: ProcessedMap.Tile,
            assets: Assets
        ) {
            self.tile = tile
            self.assets = assets
        }
        
    }
    
    @ObservedObject var model: Model
}

extension TileView {
    
    @ViewBuilder
    var body: some View {
        switch model.terrainImageState {
        case .idle: Color.white.onAppear(perform: model.loadTerrainImage)
        case .loading: Color.gray
        case .failure: Color.red
        case .loaded(let terrainImage):
            Image(decorative: terrainImage, scale: 1.0)
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
                TileView(model: .init(tile: tile, assets: model.assets))
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
        fileprivate let assets: Assets
        
        init(processedMap: ProcessedMap, assets: Assets) {
            self.processedMap = processedMap
            self.assets = assets
            
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
    init(processedMap: ProcessedMap, assets: Assets) {
        self.init(model: .init(processedMap: processedMap, assets: assets))
    }
}

// MARK: ProcessedMap.Tile + Identifiable
extension ProcessedMap.Tile: Identifiable {
    public typealias ID = Position
    public var id: ID { position }
}


