//
//  DefinitionFileView.swift
//  DefinitionFileView
//
//  Created by Alexander Cyon on 2021-09-19.
//

import SwiftUI
import Combine

import Makt

struct DefinitionFileView: View {
    let definitionFile: DefinitionFile
    let assets: Assets
    
    var body: some View {
        VStack {
            Text("DEF file, kine: \(String(describing: definitionFile.kind))")
            Text("Size: \(String(describing: definitionFile.width)) x \(String(describing: definitionFile.height))")
            Text("Palette: #\(definitionFile.palette.colors.count) colors")
            Text("Blocks: #\(definitionFile.blocks.count)")
            blocksView
        }
    }
    
    var blocksView: some View {
        VStack {
            ForEach(definitionFile.blocks) { block in
                DefBlockView(block: block, palette: definitionFile.palette, assets: assets)
            }
        }
    }
}

struct DefBlockView: View {
    let block: Block
    let palette: Palette
    let assets: Assets
    
    var body: some View {
        VStack {
            Divider()
                .background(Color.yellow)
                .frame(minWidth: 50, idealWidth: 100, minHeight: 3, idealHeight: 5)
            
            Text("BLOCK ID: \(block.id)")
            
            Text("Frames (#\(block.frames.count)):")
            VStack {
                ForEach(block.frames, id: \.self) { frame in
                    BlockFrameView(model: .init(frame: frame, palette: palette, assets: assets))
                }
            }
        }
    }
}

struct BlockFrameView: View {
    @ObservedObject var model: Model
    
    var body: some View {
        VStack {
            Text("\t\tFRAME: File name: \(model.frame.fileName)")
            Text("\t\tFRAME: Size: \(String(describing: model.frame.width)) x \(String(describing: model.frame.height))")
         
            switch model.state {
            case .idle:
                Button("Load image") {
                    model.loadPCXImage()
                }
            case .loading:
                Text("Loading image...")
            case .failure(let error):
                Text("Error: \(String(describing: error))")
            case .loaded(let cgImage):
                Image(decorative: cgImage, scale: 1.0)
            }
        }
    }
    
}

extension BlockFrameView {
    final class Model: ObservableObject {
        
        fileprivate let frame: DefinitionFile.Frame
        private let palette: Palette
        private var cancellables = Set<AnyCancellable>()
        @Published internal var state: LoadingState<CGImage> = .idle
        fileprivate let assets: Assets
        
        init(
            frame: DefinitionFile.Frame,
            palette: Palette,
            assets: Assets
        ) {
            self.frame = frame
            self.palette = palette
            self.assets = assets
        }
    }
}

extension BlockFrameView.Model {
    func loadPCXImage() {
        assets.loadImageFrom(
                defFilFrame: frame,
                palette: palette
            )
            .receive(on: RunLoop.main)
            .sink { [unowned self] image in
                state = .loaded(image)
            }.store(in: &cancellables)
    }

}

