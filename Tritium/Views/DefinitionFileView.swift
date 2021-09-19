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
                DefBlockView(block: block)
            }
        }
    }
}

struct DefBlockView: View {
    let block: Block
    
    var body: some View {
        VStack {
            Text("Identifier: \(block.id)")
            
            Text("Frames (#\(block.frames.count)):")
            VStack {
                ForEach(block.frames, id: \.self) { frame in
                    BlockFrameView(frame: frame)
                }
            }
        }
    }
}

struct BlockFrameView: View {
    let frame: DefinitionFile.Frame
    
    var body: some View {
        VStack {
            Text("\t\tFRAME: File name: \(frame.fileName)")
            Text("\t\tFRAME: Size: \(String(describing: frame.width)) x \(String(describing: frame.height))")
        }
    }
}
