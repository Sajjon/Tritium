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
    let assets: Assets
    var body: some View {
        switch loadedArchive {
        case .archive(let lodFile):
            LodFileView(lodFile: lodFile, assets: assets)
        case .sound(let sndFile):
            SNDFileView(sndFile: sndFile)
        case .video(let vidFile):
            VIDFileView(vidFile: vidFile)
        }
    }
}

