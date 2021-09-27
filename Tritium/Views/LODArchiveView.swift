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
    let assets: Assets
    var body: some View {
        VStack {
            Text("Lodfile: \(lodFile.lodFileName)")
            List(lodFile.entries, id: \.self) { fileEntry in
                FileEntryView(fileEntry: fileEntry, assets: assets)
            }
        }
    }
    
    struct FileEntryView: View {
       
        @ObservedObject var model: Model
        
        init(model: Model) {
            self.model = model
        }
        
        init(
            fileEntry: LodFile.FileEntry,
            assets: Assets
        ) {
            self.init(
                model: .init(
                    fileEntry: fileEntry,
                    assets: assets
                )
            )
        }
        
        var body: some View {
            VStack {
                Text("Lod file entry: \(model.fileEntryName)")
                Group {
                    switch model.state {
                    case .error(let error):
                        Text("Error loading fileEntry: \(String(describing: error))")
                    case .idle:
                        Button("Load file entry") {
                            model.loadEntry()
                        }
                    case .loading:
                        Text("Loading file entry..")
                    case .loaded(let asset):
                        loadedAssetView(asset: asset)
                    }
                }
            }
        }
        
        func loadedAssetView(asset: Model.LoadingState.Asset) -> AnyView {
            Group {
            switch asset {
            case .text(let text):
                Text("\(text)")
            case .image(let cgImage):
                Image(decorative: cgImage, scale: 1.0)
            case .definitionFile(let definitionFile):
                DefinitionFileView(definitionFile: definitionFile, assets: model.assets)
            case .campaign(let campaign):
                Text("Campaign: \(String(describing: campaign))")
            }
            }.eraseToAnyView()
        }
    }
}

extension LodFileView.FileEntryView {
    final class Model: ObservableObject {
        
        let fileEntry: LodFile.FileEntry
        fileprivate let assets: Assets
        
        @Published var state: LoadingState = .idle
        private var cancellables = Set<AnyCancellable>()
        
        public init(
            fileEntry: LodFile.FileEntry,
            assets: Assets
        ) {
            self.fileEntry = fileEntry
            self.assets = assets
        }
    }
}

private extension LodFileView.FileEntryView.Model {
    func loadPCX(_ pcxImage: PCXImage) -> AnyPublisher<CGImage, Never> {
//        assets.loadImageFrom(pcx: pcxImage).catch({ _ in
//            return Deferred<AnyPublisher<CGImage, Never>> {
//                fatalError()
//            }.eraseToAnyPublisher()
//        }).eraseToAnyPublisher()
        fatalError()
    }
}

extension LodFileView.FileEntryView.Model {
    
    var fileEntryName: String {
        fileEntry.fileName
    }
    
    enum Error: Swift.Error {
        case unsupportedAsset(kind: String)
        case failedToLoadImage
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
        case error(LodFileView.FileEntryView.Model.Error)
    }
    
    func loadEntry() {
//        state = .loading
//
//
//        switch fileEntry.content {
//        case .xmi:
//            fatalError("handle")
//        case .text(let textPublisher):
//            textPublisher
//                .receive(on: RunLoop.main)
//                .sink { [unowned self] text in
//                    state = .loaded(asset: .text(text))
//                }.store(in: &cancellables)
//        case .def(let defPublisher):
//            defPublisher
//                .receive(on: RunLoop.main)
//                .sink { [unowned self] definitionFile in
//                    state = .loaded(asset: .definitionFile(definitionFile))
//                }.store(in: &cancellables)
//        case .pcx(let pcxPublisher):
//            pcxPublisher.flatMap(loadPCX)
//                .receive(on: RunLoop.main)
//                .sink { [unowned self] image in
//                    state = .loaded(asset: .image(image))
//                }.store(in: &cancellables)
//        case .font:
//            fatalError("handle")
//        case .campaign(let campaignPublisher):
//            campaignPublisher
//                .receive(on: RunLoop.main)
//                .sink { [unowned self] campaign in
//                    state = .loaded(asset: .campaign(campaign))
//                }.store(in: &cancellables)
//        case .palette:
//            fatalError("handle")
//        case .mask(let maskPublisher):
//            maskPublisher
//                .receive(on: RunLoop.main)
//                .sink { [unowned self] mask in
//                    state = .loaded(asset: .text("Mask:\n\n\(String(describing: mask))\n"))
//                }.store(in: &cancellables)
//        }
        fatalError()
    }
}

