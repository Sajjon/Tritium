//
//  MapListView.swift
//  MapListView
//
//  Created by Alexander Cyon on 2021-09-22.
//

import SwiftUI
import Combine
import Makt

extension Map.ID: Identifiable {
    public typealias ID = String
    public var id: ID { self.fileName }
}

struct ErrorView: View {
    let error: Swift.Error
}
extension ErrorView {
    var body: some View {
        Text("Error: \(String(describing: error))")
    }
}

struct MapListView: View {
    
    @ObservedObject var model: Model

    var body: some View {
        NavigationView {
            switch model.state {
            case .idle:
                Button("Load maps") {
                    model.load()
                }
            case .failure(let error):
                ErrorView(error: error)
            case .loading:
                Text("Loading map ids...")
            case .loaded(let mapIDs):
                List(mapIDs) { mapID in
                    NavigationLink("\(mapID.name)", destination: MapView(mapID: mapID, assetLoader: model.assetLoader))
                }
            }
        }
    }
}

extension MapListView {
    final class Model: ObservableObject {
        @Published var state: LoadingState<[Map.ID]> = .idle
        
        private var cancellables = Set<AnyCancellable>()
        
        let assetLoader: AssetLoader
        
        init(assetLoader: AssetLoader) {
            self.assetLoader = assetLoader
        }
    }
}


extension MapListView.Model {
    convenience init(config: Config, fileManager: FileManager = .default) {
        self.init(assetLoader: .init(config: config, fileManager: fileManager))
    }
}

extension MapListView {
    init(config: Config, fileManager: FileManager = .default) {
        self.init(model: .init(config: config, fileManager: fileManager))
    }
}

extension MapListView.Model {
    func load() {

        state = .loading
  
        assetLoader.loadMapIDs()
            .receive(on: RunLoop.main)
            .sink(
                receiveCompletion: { [self] completion in
                    switch completion {
                    case .failure(let error):
                        state = .failure(error)
                    case .finished:
                        break
                    }
                }, receiveValue: { [self] mapIDs in
                    state = .loaded(mapIDs)
                }
            ).store(in: &cancellables)
    }
}
