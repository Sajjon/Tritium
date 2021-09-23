//
//  MapView.swift
//  Tritium
//
//  Created by Alexander Cyon on 2021-09-23.
//

import SwiftUI
import Combine
import Makt

struct ProcessedMap: Equatable {
    let map: Map
}

struct RenderMapView: View {
    let processedMap: ProcessedMap
    
    var body: some View {
        ScrollView {
            Text(processedMap.map.world.above.tileEmojiString)
                .font(.system(size: fontSize(map: processedMap.map)))
        }

    }
    
    private func fontSize(map: Map) -> CGFloat {
        switch map.basicInformation.size {
        case .small: return 24
        case .medium: return 12
        case .large: return 10
        default: return 6
        }
    }
}

struct MapView: View {
    @ObservedObject var model: Model
    
    @ViewBuilder
    var body: some View {
        switch model.state {
        case .idle:
            Color.clear.onAppear(perform: model.processMap)
        case .failure(let error):
            ErrorView(error: error)
        case .loading:
            ProgressView("Processing map for rendering...")
        case .loaded(let processedMap):
            RenderMapView(processedMap: processedMap)
        }
    }
}

extension MapView {
    final class Model: ObservableObject {
        
        private let map: Map
        
        @Published var state: LoadingState<ProcessedMap> = .idle
        
        private var cancellables = Set<AnyCancellable>()
        
        private let mapProccessor: MapProcessor
        
        public init(
            map: Map,
            mapProccessor: MapProcessor = .init()
        ) {
            self.map = map
            self.mapProccessor = mapProccessor
        }
    }
}

extension MapView.Model {
    func processMap() {
        state = .loading
        
        mapProccessor.process(map: map)
            .receive(on: RunLoop.main)
            .sink(
                receiveCompletion: { [self] completion in
                    switch completion {
                    case .failure(let error):
                        state = .failure(error)
                    case .finished:
                        break
                    }
                }, receiveValue: { [self] proccessMap in
                    state = .loaded(proccessMap)
                }
            ).store(in: &cancellables)
    }
}

final class MapProcessor {
    init() {}
}
extension MapProcessor {
    func process(map: Map) -> AnyPublisher<ProcessedMap, Never> {
        return Future<ProcessedMap, Never> { promise in
            DispatchQueue.init(label: "ProcessMap", qos: .background).async {
                let processedMap = ProcessedMap.init(map: map)
                promise(.success(processedMap))
            }
        }
        .delay(for: .seconds(1), scheduler: DispatchQueue.main)
        .eraseToAnyPublisher()
    }
}
