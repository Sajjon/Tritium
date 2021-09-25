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
    
    @ObservedObject private var model: Model
    
    init(model: Model) {
        self.model = model
    }
}


// MARK: View
extension GameFilesView {
    
    var body: some View {
        Group {
            switch model.state {
            case .error(let error):
                Text("Error loading assets: \(String(describing: error))")
            case .loading(let request):
                Text("Loading \(String(describing: request))...")
            case .idle:
                Button("Load assets") {
                    model.loadArchives()
                }
            case .loaded(let archives):
                VStack(spacing: 40) {
                    ForEach(archives) { archiveFile in
                        Button("\(archiveFile.fileName) (#\(archiveFile.data.sizeString))") {
                            model.open(archiveFile: archiveFile)
                        }.padding()
                    }
                }
            case .opened(let loadedArchive):
                ArchiveView(loadedArchive: loadedArchive, assets: model.assets)
            }
        }
       
    }
}

// MARK: ViewModel
extension GameFilesView {
    final class Model: ObservableObject {

        @Published var state: LoadingState = .idle
        
        private var cancellables = Set<AnyCancellable>()
        fileprivate let assets: Assets

        init(
            assets: Assets
        ) {
            self.assets = assets
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
        case error(GameFilesView.Model.Error)
        case opened(LoadedArchive)
    }
    
}


// MARK: ViewModel Error
extension GameFilesView.Model {
    
    enum Error: Swift.Error {
        case unsupportedAsset(kind: String)
        case failedToLoadAssetList
        case failedToOpenArchive
    }
}

// MARK: Load
extension GameFilesView.Model {
    func loadArchives() {
        state = .loading(.archives)
        
        assets.loadArchives()
            .receive(on: RunLoop.main)
            .sink { [self] assetFiles in
                state = .loaded(assetFiles)
            }.store(in: &cancellables)
    }
}

// MARK: Open
extension GameFilesView.Model {
    func open(archiveFile: ArchiveFile) {
        defer { state = .loading(.archiveFile(archiveFile)) }
        
        assets.load(archiveFile: archiveFile) // .load(archiveFile: archiveFile)
            .receive(on: RunLoop.main)
            .sink { [self] loadedAsset in
                state = .opened(loadedAsset)
            }.store(in: &cancellables)
        
    }
}

// MARK: ArchiveFile + ID
extension ArchiveFile: Identifiable {
    public var id: String { fileName }
}
