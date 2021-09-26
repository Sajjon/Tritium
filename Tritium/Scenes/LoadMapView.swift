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
                    NavigationLink(
                        "Render map",
                        destination: ProcessMapView(model: .init(map: map, assets: model.assets)))
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
        
        private let mapPublisher: AnyPublisher<Map, Never>
        fileprivate let assets: Assets
        
        init(
            basicMapInfo: Map.BasicInformation,
            assets: Assets
//            mapPublisher: AnyPublisher<Map, Assets.Error>
        ) {
            self.assets = assets
            self.basicMapInfo = basicMapInfo
            self.mapPublisher = assets.loadMap(id: basicMapInfo.id)
        }
    }
}


extension LoadMapView {
    init(basicMapInfo: Map.BasicInformation, assets: Assets) {
        self.init(
            model: .init(basicMapInfo: basicMapInfo, assets: assets)
        )
    }
}


extension LoadMapView.Model {
    func load() {
        state = .loading(progress: nil)
        
        mapPublisher
            .receive(on: RunLoop.main)
            .sink(
                receiveCompletion: { [unowned self] completion in
                    switch completion {
                    case .failure(let error):
                        state = .failure(error)
                    case .finished:
                        break
                    }
                    
                }, receiveValue: { [unowned self] map in
                    
                    state = .loaded(map)
                }
            ).store(in: &cancellables)
    }
}
