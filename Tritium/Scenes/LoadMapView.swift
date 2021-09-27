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
            self.mapPublisher = Publishers.noFail(async: try assets.loadMap(id: basicMapInfo.id))
        }
    }
}

extension Publishers {
    static func noFail<Value>(async syncDo: @autoclosure @escaping () throws -> Value) -> AnyPublisher<Value, Never> {
        noFailAsync(syncDo)
    }
    
    static func noFailAsync<Value>(_ syncDo: @escaping () throws -> Value) -> AnyPublisher<Value, Never> {
        Deferred {
            Future<Value, Never> { promise in
                DispatchQueue.global(qos: .background).async {
                    do {
                        let value = try syncDo()
                        promise(.success(value))
                    } catch {
                        uncaught(error: error)
                    }
                }
            }
        }
        .receive(on: RunLoop.main)
        .eraseToAnyPublisher()
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
