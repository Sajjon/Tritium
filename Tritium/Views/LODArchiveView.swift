//
//  LODArchiveView.swift
//  LODArchiveView
//
//  Created by Alexander Cyon on 2021-09-22.
//

import SwiftUI
import Combine
import Makt

struct LodFileView: View {
    let lodFile: LodFile
    let imageLoader: ImageLoader
    var body: some View {
        VStack {
            Text("Lodfile: \(lodFile.lodFileName)")
            List(lodFile.entries, id: \.self) { fileEntry in
                FileEntryView(fileEntry: fileEntry, imageLoader: imageLoader)
            }
        }
    }
    
    struct FileEntryView: View {
       
        @ObservedObject var viewModel: ViewModel
        
        init(viewModel: ViewModel) {
            self.viewModel = viewModel
        }
        
        init(
            fileEntry: LodFile.FileEntry,
            imageLoader: ImageLoader = .init()
        ) {
            self.init(
                viewModel: .init(
                    fileEntry: fileEntry,
                    imageLoader: imageLoader)
            )
        }
        
        var body: some View {
            VStack {
                Text("Lod file entry: \(viewModel.fileEntryName)")
                Group {
                    switch viewModel.state {
                    case .error(let error):
                        Text("Error loading fileEntry: \(String(describing: error))")
                    case .idle:
                        Button("Load file entry") {
                            viewModel.loadEntry()
                        }
                    case .loading:
                        Text("Loading file entry..")
                    case .loaded(let asset):
                        loadedAssetView(asset: asset)
                    }
                }
            }
        }
        
        func loadedAssetView(asset: ViewModel.LoadingState.Asset) -> AnyView {
            Group {
            switch asset {
            case .text(let text):
                Text("\(text)")
            case .image(let cgImage):
                Image(decorative: cgImage, scale: 1.0)
            case .definitionFile(let definitionFile):
                DefinitionFileView(definitionFile: definitionFile)
            case .campaign(let campaign):
                Text("Campaign: \(campaign.header.name)")
            }
            }.eraseToAnyView()
        }
    }
}

extension LodFileView.FileEntryView {
    final class ViewModel: ObservableObject {
        
        let fileEntry: LodFile.FileEntry
        private let imageLoader: ImageLoader
        
        @Published var state: LoadingState = .idle
        private var cancellables = Set<AnyCancellable>()
        
        public init(
            fileEntry: LodFile.FileEntry,
            imageLoader: ImageLoader = .init()
        ) {
            self.fileEntry = fileEntry
            self.imageLoader = imageLoader
        }
    }
}

private extension LodFileView.FileEntryView.ViewModel {
    func loadPCX(_ pcxImage: PCXImage) -> AnyPublisher<CGImage, Never> {
        imageLoader.loadImageFrom(pcx: pcxImage).catch({ _ in
            return Deferred<AnyPublisher<CGImage, Never>> {
                fatalError()
            }.eraseToAnyPublisher()
        }).eraseToAnyPublisher()
    }
}

extension LodFileView.FileEntryView.ViewModel {
    
    var fileEntryName: String {
        fileEntry.name
    }
    
    enum Error: Swift.Error {
        case unsupportedAsset(kind: String)
        case failedToLoadImage(ImageLoader.Error)
    }
    
    enum LoadingState {
        enum Asset {
            case text(String)
            case image(CGImage)
            case definitionFile(DefinitionFile)
            case campaign(Campaign)
        }
 
        case idle
        case loading
        case loaded(asset: Asset)
        case error(LodFileView.FileEntryView.ViewModel.Error)
    }
    
    func loadEntry() {
        state = .loading
        

        switch fileEntry.content {
        case .xmi:
            fatalError("handle")
        case .text(let textPublisher):
            textPublisher
                .receive(on: RunLoop.main)
                .sink { [self] text in
                    state = .loaded(asset: .text(text))
                }.store(in: &cancellables)
        case .def(let defPublisher):
            defPublisher
                .receive(on: RunLoop.main)
                .sink { [self] definitionFile in
                    state = .loaded(asset: .definitionFile(definitionFile))
                }.store(in: &cancellables)
        case .pcx(let pcxPublisher):
            pcxPublisher.flatMap(loadPCX)
                .receive(on: RunLoop.main)
                .sink { [self] image in
                    state = .loaded(asset: .image(image))
                }.store(in: &cancellables)
        case .font:
            fatalError("handle")
        case .campaign(let campaignPublisher):
            campaignPublisher
                .receive(on: RunLoop.main)
                .sink { [self] campaign in
                    state = .loaded(asset: .campaign(campaign))
                }.store(in: &cancellables)
        case .palette:
            fatalError("handle")
        case .mask(let maskPublisher):
            maskPublisher
                .receive(on: RunLoop.main)
                .sink { [self] mask in
                    state = .loaded(asset: .text("Mask:\n\n\(String(describing: mask))\n"))
                }.store(in: &cancellables)
        }
    }
}

