//
//  MapView.swift
//  Tritium
//
//  Created by Alexander Cyon on 2021-09-22.
//

import SwiftUI
import Combine
import Makt

struct MapView: View {
    
    @ObservedObject var model: Model
    
    var body: some View {
        switch model.state {
        case .idle:
            Button("Load map: \(model.mapID.name)") {
                model.load()
            }
        case .failure(let error):
            ErrorView(error: error)
        case .loading:
            ProgressView("Loading map...")
        case .loaded(let map):
            ScrollView {
                Text(map.world.above.tileEmojiString)
            }
        }
    }
}


extension MapView {
    final class Model: ObservableObject {
        @Published var state: LoadingState<Map> = .idle
        
        private var cancellables = Set<AnyCancellable>()
        
        fileprivate let mapID: Map.ID
        
        private let mapPublisher: AnyPublisher<Map, AssetLoader.Error>
        
        init(mapID: Map.ID, mapPublisher: AnyPublisher<Map, AssetLoader.Error>) {
            self.mapID = mapID
            self.mapPublisher = mapPublisher
        }
    }
}


extension MapView.Model {
    
    convenience init(mapID: Map.ID, assetLoader: AssetLoader) {
        self.init(mapID: mapID, mapPublisher: assetLoader.loadMap(id: mapID))
    }
    
    convenience init(mapID: Map.ID, config: Config, fileManager: FileManager = .default) {
        self.init(mapID: mapID, assetLoader: .init(config: config, fileManager: fileManager))
    }
}

extension MapView {
    init(mapID: Map.ID, assetLoader: AssetLoader) {
        self.init(
            model: .init(mapID: mapID, assetLoader: assetLoader)
        )
    }
}


extension MapView.Model {
    func load() {
        state = .loading
        
        mapPublisher
            .receive(on: RunLoop.main)
            .sink(
                receiveCompletion: { [self] completion in
                    switch completion {
                    case .failure(let error):
                        state = .failure(error)
                    case .finished:
                        break
                    }
                    
                }, receiveValue: { [self] map in
                  
                    state = .loaded(map)
                }
            ).store(in: &cancellables)
    }
}
