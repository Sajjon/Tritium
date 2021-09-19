//
//  DefinitionFileView.swift
//  DefinitionFileView
//
//  Created by Alexander Cyon on 2021-09-19.
//

import Foundation
import SwiftUI
import Guld

struct DefinitionFileView: View {
    let definitionFile: DefinitionFile
    
    var body: some View {
        VStack {
            Text("DEF file, kine: \(String(describing: definitionFile.kind))")
            Text("Size: \(String(describing: definitionFile.width)) x \(String(describing: definitionFile.height))")
            Text("Palette: #\(definitionFile.palette.colors.count) colors")
            Text("Blocks")
            blocksView
        }
    }
    
    var blocksView: some View {
        VStack {
            ForEach(definitionFile.blocks) { block in
                DefBlockView(block: block, palette: definitionFile.palette)
            }
        }
    }
}

struct DefBlockView: View {
    let block: Block
    let palette: Palette
    
    var body: some View {
        VStack {
            Text("Identifier: \(block.id)")
            
            Text("Frames (#\(block.frames.count)):")
            VStack {
                ForEach(block.frames, id: \.self) { frame in
                    BlockFrameView(viewModel: .init(frame: frame, palette: palette))
                }
            }
        }
    }
}

struct BlockFrameView: View {
    @ObservedObject var viewModel: ViewModel
    
    var body: some View {
        VStack {
            Text("\t\tFRAME: File name: \(viewModel.frame.fileName)")
            Text("\t\tFRAME: Size: \(String(describing: viewModel.frame.width)) x \(String(describing: viewModel.frame.height))")
         
            switch viewModel.state {
            case .idle:
                Button("Load image") {
                    viewModel.loadPCXImage()
                }
            case .loading:
                Text("Loading image...")
            case .error(let error):
                Text("Error: \(String(describing: error))")
            case .loaded(let cgImage):
                Image(decorative: cgImage, scale: 1.0)
            }
        }
    }
    
}

extension BlockFrameView {
    final class ViewModel: ObservableObject {
        
        enum LoadingState {
            case idle
            case loading
            case error(Swift.Error)
            case loaded(CGImage)
        }
        
        fileprivate let frame: DefinitionFile.Frame
        private let palette: Palette
        private var cancellables = Set<AnyCancellable>()
        @Published internal var state: LoadingState = .idle
        private let imageLoader: ImageLoader
        
        init(
            frame: DefinitionFile.Frame,
            palette: Palette,
            imageLoader: ImageLoader = .init()
        ) {
            self.frame = frame
            self.palette = palette
            self.imageLoader = imageLoader
        }
    }
}

import Combine
extension BlockFrameView.ViewModel {
    func loadPCXImage() {
            imageLoader.loadImageFrom(
                pixelData: frame.pixelData, width: frame.width, palette: palette
            )
            .crashOnError()
            .receive(on: RunLoop.main)
            .sink { [self] image in
                state = .loaded(image)
            }.store(in: &cancellables)
    }

}

import Util

extension Publisher {
    func crashOnError() -> AnyPublisher<Output, Never> {
        return self.catch({ error in
            return Deferred<AnyPublisher<Output, Never>> {
                uncaught(error: error)
                       }.eraseToAnyPublisher()
        }).eraseToAnyPublisher()
    }
}
