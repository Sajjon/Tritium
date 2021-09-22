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

// MARK: GameFilesView
struct GameFilesView: View {
    
    @ObservedObject private var viewModel: ViewModel
    
    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }
}

// MARK: GameFilesView Init
extension GameFilesView {
    init(config: Config) {
        self.init(viewModel: .init(config: config))
    }
}

// MARK: View
extension GameFilesView {
    
    var body: some View {
        Group {
            switch viewModel.state {
            case .error(let error):
                Text("Error loading assets: \(String(describing: error))")
            case .loading(let request):
                Text("Loading \(String(describing: request))...")
            case .idle:
                Button("Load assets") {
                    viewModel.loadArchives()
                }
            case .loaded(let archives):
                VStack(spacing: 40) {
                    ForEach(archives) { archiveFile in
                        Button("\(archiveFile.fileName) (#\(archiveFile.data.sizeString))") {
                            viewModel.open(archiveFile: archiveFile)
                        }.padding()
                    }
                }
            case .opened(let loadedArchive):
                ArchiveView(loadedArchive: loadedArchive, imageLoader: viewModel.imageLoader)
            }
        }
       
    }
}

// MARK: ViewModel
extension GameFilesView {
    final class ViewModel: ObservableObject {

        @Published var state: LoadingState = .idle
        
        private var cancellables = Set<AnyCancellable>()
        private let assetLoader: AssetLoader
        private let archiveLoader: ArchiveLoader
        let imageLoader: ImageLoader

        init(
            assetLoader: AssetLoader,
            archiveLoader: ArchiveLoader = .init(),
            imageLoader: ImageLoader
        ) {
            self.assetLoader = assetLoader
            self.archiveLoader = archiveLoader
            self.imageLoader = imageLoader
        }
    }
}

// MARK: ViewModel LoadingState
extension GameFilesView {
    enum LoadingState {
        
        enum UserRequest: Equatable {
            case archives
            case archiveFile(ArchiveFile)
        }
        
        case idle
        case loading(UserRequest)
        case loaded([ArchiveFile])
        case error(GameFilesView.ViewModel.Error)
        case opened(LoadedArchive)
    }
    
}

// MARK: ViewModel Init
extension GameFilesView.ViewModel {
    convenience init(config: Config, imageLoader: ImageLoader = .init()) {
        self.init(assetLoader: .init(config: config), imageLoader: imageLoader)
    }
}

// MARK: ViewModel Error
extension GameFilesView.ViewModel {
    
    enum Error: Swift.Error {
        case unsupportedAsset(kind: String)
        case failedToLoadAssetList(AssetLoader.Error)
        case failedToOpenArchive(ArchiveLoader.Error)
    }
}

// MARK: Load
extension GameFilesView.ViewModel {
    func loadArchives() {
        state = .loading(.archives)
        
        assetLoader.loadArchives()
            .receive(on: RunLoop.main)
            .sink { [self] completion in
                switch completion {
                case .failure(let error):
                    state = .error(.failedToLoadAssetList(error))
                case .finished: break
                }
            } receiveValue: { [self] assetFiles in
                state = .loaded(assetFiles)
            }.store(in: &cancellables)
    }
}

// MARK: Open
extension GameFilesView.ViewModel {
    func open(archiveFile: ArchiveFile) {
        defer { state = .loading(.archiveFile(archiveFile)) }
        
        archiveLoader.load(archiveFile: archiveFile)
            .receive(on: RunLoop.main)
            .sink { [self] completion in
                switch completion {
                case .failure(let error):
                    state = .error(.failedToOpenArchive(error))
                case .finished: break
                }
            } receiveValue: { [self] loadedAsset in
                state = .opened(loadedAsset)
            }.store(in: &cancellables)
        
    }
}

// MARK: ArchiveFile + ID
extension ArchiveFile: Identifiable {
    public var id: String { fileName }
}
