//
//  LoadMapView.swift
//  Tritium
//
//  Created by Alexander Cyon on 2021-09-22.
//

import SwiftUI
import Combine
import Makt

extension Map {
    var summary: String {
        let basicInformation = basicInformation
        return """
            Name: \(basicInformation.name)
            Size: \(basicInformation.size)
            Players: \(playersInfo.players.count)/\(playersInfo.players.filter { $0.isPlayableByHuman }.count)
            """
    }
}


struct LoadMapView: View {
    
    @ObservedObject var model: Model
    
    var body: some View {
        NavigationView {
            switch model.state {
            case .idle:
                Button("Load map: \(model.basicMapInfo.name) (parse)") {
                    model.load()
                }
            case .failure(let error):
                ErrorView(error: error)
            case .loading:
                ProgressView("Loading map...(Parsing)")
            case .loaded(let map):
                VStack {
                    Text(map.summary)
                    NavigationLink("Render map", destination: ProcessMapView(model: .init(map: map)))
                }
            }
        }
    }
}


extension LoadMapView {
    final class Model: ObservableObject {
        @Published var state: LoadingState<Map> = .idle
        
        private var cancellables = Set<AnyCancellable>()
        
        fileprivate let basicMapInfo: Map.BasicInformation
        
        private let mapPublisher: AnyPublisher<Map, AssetLoader.Error>
        
        init(basicMapInfo: Map.BasicInformation, mapPublisher: AnyPublisher<Map, AssetLoader.Error>) {
            self.basicMapInfo = basicMapInfo
            self.mapPublisher = mapPublisher
        }
    }
}


extension LoadMapView.Model {
    
    convenience init(basicMapInfo: Map.BasicInformation, assetLoader: AssetLoader) {
        self.init(basicMapInfo: basicMapInfo, mapPublisher: assetLoader.loadMap(id: basicMapInfo.id))
    }
    
    convenience init(basicMapInfo: Map.BasicInformation, config: Config, fileManager: FileManager = .default) {
        self.init(basicMapInfo: basicMapInfo, assetLoader: .init(config: config, fileManager: fileManager))
    }
}

extension LoadMapView {
    init(basicMapInfo: Map.BasicInformation, assetLoader: AssetLoader) {
        self.init(
            model: .init(basicMapInfo: basicMapInfo, assetLoader: assetLoader)
        )
    }
}


extension LoadMapView.Model {
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
