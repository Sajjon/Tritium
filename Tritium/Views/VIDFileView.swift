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
        @Published var extractedVideoURL: URL? = nil
        private var cancellables = Set<AnyCancellable>()
        
        func extractVideo() {
            videoExtractor.extract(
                data: videoFileEntry.contents,
                name: videoFileEntry.fileName //,
//                outputURL: "cyon_homm3.mov"
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
                        self.extractedVideoURL = $0
                    }
                ).store(in: &cancellables)
        }
    }
    
    
    var body: some View {
        VStack {
            
            Text("Name: \(viewModel.videoFileEntry.fileName) - #\(viewModel.videoFileEntry.contents.sizeString)")
            
            if let videoURL = viewModel.extractedVideoURL {
                Button("Play Video") {
                    // IMPORTANT: For more advanced playback capabilities, use: AVAudioEngine
                    // https://developer.apple.com/documentation/avfaudio/avaudioengine
                    let videoPlayer = try! AVAudioPlayer(
                        contentsOf: videoURL,
                        fileTypeHint: "mov"
                    )
                    videoPlayer.play()
                }
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
