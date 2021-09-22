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

struct ArchiveView: View {
    let loadedArchive: LoadedArchive
    let imageLoader: ImageLoader
    var body: some View {
        switch loadedArchive {
        case .archive(let lodFile):
            LodFileView(lodFile: lodFile, imageLoader: imageLoader)
        case .sound(let sndFile):
            SNDFileView(sndFile: sndFile)
        case .video(let vidFile):
            VIDFileView(vidFile: vidFile)
        }
    }
}

