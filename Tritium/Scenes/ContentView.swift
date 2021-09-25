//
//  ContentView.swift
//  ContentView
//
//  Created by Alexander Cyon on 2021-09-17.
//

import SwiftUI
import Combine

import Makt


struct AnyError: Swift.Error, CustomStringConvertible {
    let description: String
}


struct ContentView: View {

    
    final class Model: ObservableObject {
        enum ViewSelection {
            case archiveList
            case mapList
        }
        
        @Published var selection: ViewSelection = .mapList
        @Published var config: Config? {
            didSet {
                state = .idle
            }
        }
        @Published var state: LoadingState<Assets> = AssetsProvider.sharedAssets.map({ .loaded($0) }) ?? .idle
        
        private let loadingProgressSubject = PassthroughSubject<LoadingProgress, Never>()
        
        fileprivate var cancellables = Set<AnyCancellable>()
        
        func provideAssets() {
            guard let config = config else {
                state = .failure(AnyError(description: "Cant provide assets without config."))
                return
            }
            state = .loading(progress: LoadingProgress.step(named: "Initiating loading of archives."))
            AssetsProvider.provide(
                config: config,
                progressSubject: loadingProgressSubject
            ).receive(on: RunLoop.main)
                .sink(receiveValue: { [self] assets in
                    state = .loaded(assets)
                }).store(in: &cancellables)
            
            loadingProgressSubject
                .receive(on: RunLoop.main)
                .sink(receiveValue: { [self] progress in
                guard !state.isLoaded else { return }
                state = .loading(progress: progress)
            }).store(in: &cancellables)
        }
    }
    
    @ObservedObject var model: Model = .init()
    
    
    var body: some View {
        if  model.config != nil {
            switch model.state {
            case .idle:
                Button("Provide assets (might take a minute)") {
                    model.provideAssets()
                }
            case .failure(let error):
                ErrorView(error: error)
            case .loaded(let assets):
                viewsRequiring(assets: assets)
            case .loading(let maybeProgress):
                    VStack {
                        Text("Loading")
                        view(progress: maybeProgress)
                    }
            }
            
        } else {
            ConfigView(config: $model.config)
        }
        
    }
    
    @ViewBuilder
    func view(progress: LoadingProgress?) -> some View {
        if let progress = progress  {
            Text("Loading: \(String(describing: progress))")
        } else {
            EmptyView()
        }
    }
    
    func viewsRequiring(assets: Assets) -> some View {
        VStack {
            Picker("Open asset class", selection: $model.selection) {
                Text("Maps").tag(Model.ViewSelection.mapList)
                Text("Archives").tag(Model.ViewSelection.archiveList)
            }.pickerStyle(SegmentedPickerStyle()).frame(minHeight: 60)
            
            Group {
                switch model.selection {
                case .archiveList:
                    GameFilesView(model: .init(assets: assets))
                case .mapList:
                    MapListView(model: .init(assets: assets))
                }
            }
        }
    }
    

}
