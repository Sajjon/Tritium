//
//  VIDFileView.swift
//  VIDFileView
//
//  Created by Alexander Cyon on 2021-09-20.
//

import Foundation
import SwiftUI
import Guld
import Video
import AVFoundation
import Combine

struct VIDFileView: View {
    let vidFile: VIDFile
    var body: some View {
        VStack {
            Text("VID File: \(vidFile.videoArchiveFileName)")
            List(vidFile.fileEntries, id: \.self) { videoFileEntry in
                VideoFileView(viewModel: .init(videoFileEntry: videoFileEntry))
            }
        }
    }
}

import AVKit
struct VideoFileView: View {
    
    
    @ObservedObject var viewModel: ViewModel
    
    final class ViewModel: ObservableObject {
        let videoFileEntry: VIDFile.FileEntry
        private let videoExtractor: VideoExtractor
        
        init(videoFileEntry: VIDFile.FileEntry, videoExtractor: VideoExtractor = .init()) {
            self.videoFileEntry = videoFileEntry
            self.videoExtractor = videoExtractor
        }
        
        @Published var extactVideoError: Swift.Error? = nil
        @Published var avPlayer: AVPlayer? = nil
        private var cancellables = Set<AnyCancellable>()
        
        func extractVideo() {
            
            //  Find Application Support directory
            let fileManager = FileManager.default
            let appSupportURL = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
            
            let containingDirectoryURL = appSupportURL.appendingPathComponent("Makt")
            
            try! fileManager.createDirectory(
                at: containingDirectoryURL,
                withIntermediateDirectories: true,
                attributes: nil)
            
            let temporaryDirectory = containingDirectoryURL.appendingPathComponent("Temp")
            
            try! fileManager.createDirectory(
                at: temporaryDirectory,
                withIntermediateDirectories: true,
                attributes: nil)
            
            let outputDirectory = containingDirectoryURL.appendingPathComponent("Converted")
            
            try! fileManager.createDirectory(
                at: outputDirectory,
                withIntermediateDirectories: true,
                attributes: nil)
            
            
            videoExtractor.extract(
                data: videoFileEntry.contents,
                name: videoFileEntry.fileName,
                temporaryDirectory: temporaryDirectory,
                outputDirectory: outputDirectory
            )
                .receive(on: RunLoop.main).sink(
                    receiveCompletion: { [self] completion in
                        switch completion {
                        case .failure(let error):
                            extactVideoError = error
                        case .finished:
                            break
                        }
                        
                    }, receiveValue: {
                        self.avPlayer = AVPlayer(url: $0)
                    }
                ).store(in: &cancellables)
        }
    }
    
    
    var body: some View {
        VStack {
            
            Text("Name: \(viewModel.videoFileEntry.fileName) - #\(viewModel.videoFileEntry.contents.sizeString)")
            
            if let player = viewModel.avPlayer {
                VideoPlayer(player: player)
                    .frame(width: 200, height: 116)
            } else {
                if let error = viewModel.extactVideoError {
                    Text("Failed to extract video, error: \(String(describing: error))")
                } else {
                    Button("Extract video") {
                        viewModel.extractVideo()
                    }
                }
            }
        }
    }
}
