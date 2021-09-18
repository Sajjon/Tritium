//
//  AssetView.swift
//  AssetView
//
//  Created by Alexander Cyon on 2021-09-17.
//

import Foundation
import SwiftUI
import Guld
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
                    case .loaded(let cgImage):
                        SwiftUI.Image.init(decorative: cgImage, scale: 1.0)
                    case .loadedText(let text):
                        Text("\(text)")
                    }
                }
            }
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
    func loadPCX(_ pcxImage: PCXImage) -> AnyPublisher<CGImage, ImageLoader.Error> {
        imageLoader.loadImageFrom(pcx: pcxImage)
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
 
        case idle
        case loading
        case loaded(CGImage)
        case loadedText(String)
        case error(LodFileView.FileEntryView.ViewModel.Error)
    }
    
    func loadEntry() {
        state = .loading
        

        switch fileEntry.content {
        case .text(let textPublisher):
            textPublisher
                .sink { [self] text in
                    state = .loadedText(text)
                }.store(in: &cancellables)
        case .def(let defPublisher):
            fatalError("handle")
        case .pcx(let pcxPublisher):
            pcxPublisher.flatMap(loadPCX).receive(on: RunLoop.main)
                            .sink { [self] completion in
                                switch completion {
                                case .failure(let error):
                                    state = .error(.failedToLoadImage(error))
                                case .finished: break
                                }
                            } receiveValue: { [self] image in
                                state = .loaded(image)
                            }.store(in: &cancellables)
        case .font(let fontPubliser):
            fatalError("handle")
        case .campaign(let campaignPublisher):
            fatalError("handle")
        case .palette(let palettePublisher):
            fatalError("handle")
        }
    }
}

