//
//  ProcessMapView.swift
//  Tritium
//
//  Created by Alexander Cyon on 2021-09-23.
//

import SwiftUI
import Combine
import Makt
import Guld

struct ProcessMapView: View {
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

extension ProcessMapView {
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

extension ProcessMapView.Model {
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
