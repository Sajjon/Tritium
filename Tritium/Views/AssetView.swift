//
//  AssetView.swift
//  AssetView
//
//  Created by Alexander Cyon on 2021-09-17.
//

import Foundation
import SwiftUI
import Guld
import Util
import Combine

struct AssetView: View {
    let loadedAsset: LoadedAsset
    let imageLoader: ImageLoader
    var body: some View {
        switch loadedAsset {
        case .archive(let lodFile):
            LodFileView(lodFile: lodFile, imageLoader: imageLoader)
        }
    }
}

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
                    case .loaded(let resource):
                        loadedResourceView(resource: resource)
                    }
                }
            }
        }
        
        func loadedResourceView(resource: ViewModel.LoadingState.Resource) -> AnyView {
            Group {
            switch resource {
            case .text(let text):
                Text("\(text)")
            case .image(let cgImage):
                Image(decorative: cgImage, scale: 1.0)
            case .definitionFile(let definitionFile):
                DefinitionFileView(definitionFile: definitionFile)
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
        enum Resource {
            case text(String)
            case image(CGImage)
            case definitionFile(DefinitionFile)
        }
 
        case idle
        case loading
        case loaded(resource: Resource)
        case error(LodFileView.FileEntryView.ViewModel.Error)
    }
    
    func loadEntry() {
        state = .loading
        

        switch fileEntry.content {
        case .text(let textPublisher):
            textPublisher
                .receive(on: RunLoop.main)
                .sink { [self] text in
                    state = .loaded(resource: .text(text))
                }.store(in: &cancellables)
        case .def(let defPublisher):
            defPublisher
                .receive(on: RunLoop.main)
                .sink { [self] definitionFile in
                    state = .loaded(resource: .definitionFile(definitionFile))
                }.store(in: &cancellables)
        case .pcx(let pcxPublisher):
            pcxPublisher.flatMap(loadPCX)
                .receive(on: RunLoop.main)
                .sink { [self] image in
                    state = .loaded(resource: .image(image))
                }.store(in: &cancellables)
        case .font(let fontPubliser):
            fatalError("handle")
        case .campaign(let campaignPublisher):
            fatalError("handle")
        case .palette(let palettePublisher):
            fatalError("handle")
        case .mask(let maskPublisher):
            maskPublisher
                .receive(on: RunLoop.main)
                .sink { [self] mask in
                    state = .loaded(resource: .text("Mask:\n\n\(String(describing: mask))\n"))
                }.store(in: &cancellables)
        }
    }
}

