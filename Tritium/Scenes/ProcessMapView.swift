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
            RenderMapView(processedMap: processedMap, assets: model.assets)
        }
    }
}

extension ProcessMapView {
    final class Model: ObservableObject {
        
        private let map: Map
        
        @Published var state: LoadingState<ProcessedMap> = .idle
        
        private var cancellables = Set<AnyCancellable>()
        
        private let mapProccessor: MapProcessor
        fileprivate let assets: Assets
        
        public init(
            map: Map,
            assets: Assets
        ) {
            self.map = map
            self.assets = assets
            self.mapProccessor = .init(assets: assets)
        }
    }
}

extension ProcessMapView.Model {
    func processMap() {
        state = .loading(progress: nil)
        
        Publishers.noFailAsync { [unowned self] in try self.mapProccessor.process(map: map) }
            .sink(
                receiveValue: { [unowned self] processedMap in
                    state = .loaded(processedMap)
                }
            ).store(in: &cancellables)
    }
}
