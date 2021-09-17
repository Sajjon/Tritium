//
//  GameFilesView.swift
//  GameFilesView
//
//  Created by Alexander Cyon on 2021-09-17.
//

import SwiftUI
import Malm
import Guld
import Combine

extension Int {
    
    static let mega: Self = Self.kilo * .kilo
    static let kilo: Self = 1_000

}

extension Data {
    var sizeString: String {
        let bytes = count
        if bytes >= .mega {
            return "\(megabytes) mb"
        }
        if bytes >= .kilo {
            return "\(kilobytes) kb"
        }
        
        return "\(bytes) bytes"
    }
    
    var megabytes: Int {
        count / .mega
    }
    
    var kilobytes: Int {
        count / .kilo
    }
}

extension AssetFile: Identifiable {
    public var id: String { fileName }
}

struct GameFilesView: View {
    
    @ObservedObject private var viewModel: ViewModel
    
    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }
    
    init(config: Config) {
        self.init(viewModel: .init(config: config))
    }
    
    var body: some View {
        Group {
            
            switch viewModel.state {
            case .error(let error):
                Text("Error loading assets: \(String(describing: error))")
            case .loading:
                Text("Loading assets...")
            case .idle:
                Button("Load assets") {
                    viewModel.loadAssets()
                }
            case .loaded(let assets):
                VStack {
                    ForEach(assets) { assetFile in
                        Text("\(assetFile.fileName) (#\(assetFile.data.sizeString))")
                    }
                }
            }
        }
       
    }
}

extension GameFilesView {
    final class ViewModel: ObservableObject {
        enum LoadingState {
            case idle
            case loading
            case loaded([AssetFile])
            case error(AssetLoader.Error)
        }
        
        private var cancellables = Set<AnyCancellable>()
        
        @Published var state: LoadingState = .idle
        
        private let assetLoader: AssetLoader
        init(assetLoader: AssetLoader) {
            self.assetLoader = assetLoader
        }
    }
}

extension GameFilesView.ViewModel {
    convenience init(config: Config) {
        self.init(assetLoader: .init(config: config))
    }
}

extension GameFilesView.ViewModel {
    func loadAssets() {
        state = .loading
        assetLoader.loadAll()
            .receive(on: RunLoop.main)
            .sink { [self] completion in
            switch completion {
            case .failure(let error):
                state = .error(error)
            case .finished: break
            }
        } receiveValue: { [self] assetFiles in
            state = .loaded(assetFiles)
        }.store(in: &cancellables)

    }
}
