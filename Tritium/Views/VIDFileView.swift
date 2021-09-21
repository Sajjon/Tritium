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
import Util

extension FileManager {
    var applicationSupportURL: URL {
        urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
    }
}

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

enum LoadingState<Model, Failure: Swift.Error> {
    case idle
    case loading
    case loaded(Model)
    case failure(Failure)
}

import AVKit
struct VideoFileView: View {
    
    
    @ObservedObject var viewModel: ViewModel
    
    final class ViewModel: ObservableObject {
        let videoFileEntry: VIDFile.FileEntry
        private let videoExtractor: VideoExtractor
        private let fileManager: FileManager
        
        init(
            videoFileEntry: VIDFile.FileEntry,
            fileManager: FileManager = .default,
            videoExtractor: VideoExtractor = .init()
        ) {
            self.videoFileEntry = videoFileEntry
            self.videoExtractor = videoExtractor
            self.fileManager = fileManager
            
            createDirectoriesIfNeeded()
            if fileManager.fileExists(atPath: videoFileURL.path) {
                state = .loaded(AVPlayer(url: videoFileURL))
            }
        }
        
//        @Published var extactVideoError: Swift.Error? = nil
//        @Published var avPlayer: AVPlayer? = nil
        typealias State = LoadingState<AVPlayer, Swift.Error>
        @Published var state: State = .idle
        
        private var cancellables = Set<AnyCancellable>()
        
        private lazy var appSupportURL: URL = { fileManager.applicationSupportURL }()
        private lazy var containingDirectoryURL: URL = {  appSupportURL.appendingPathComponent("Makt") }()
        private lazy var temporaryDirectory: URL = {  containingDirectoryURL.appendingPathComponent("Temp") }()
        private lazy var videoDirectory: URL = {  containingDirectoryURL.appendingPathComponent("Converted") }()
        private lazy var videoFileURL: URL = { videoDirectory.appendingPathComponent([videoFileEntry.name, VideoExtractor.fileExtension].joined(separator: ".")) }()
        
        private func createDirectoriesIfNeeded() {
            do {
                try [temporaryDirectory, videoDirectory].forEach {
                    try fileManager.createDirectory(
                        at: $0,
                        withIntermediateDirectories: true,
                        attributes: nil
                    )
                }
            } catch {
                incorrectImplementation(shouldAlwaysBeAbleTo: "Create directory")
            }
        }
        
        func extractVideo() {
            state = .loading
            videoExtractor.extract(
                data: videoFileEntry.contents,
                name: videoFileEntry.name,
                temporaryDirectory: temporaryDirectory,
                outputDirectory: videoDirectory
            )
                .receive(on: RunLoop.main).sink(
                    receiveCompletion: { [self] completion in
                        switch completion {
                        case .failure(let error):
                            state = .failure(error)
                        case .finished:
                            break
                        }
                        
                    }, receiveValue: { [self] url in
                        assert(url == videoFileURL)
                        print("✅ successfully converted video: \(url)")
                        state = .loaded(AVPlayer(url: url))
                    }
                ).store(in: &cancellables)
        }
    }
    
    
    var body: some View {
        VStack {
            Text("Name: \(viewModel.videoFileEntry.fileName) - #\(viewModel.videoFileEntry.contents.sizeString)")
            stateView
        }
    }
    
    @ViewBuilder
    var stateView: some View {
        switch viewModel.state {
        case .loading: Text("Loading...")
        case .idle:
            Button("Extract video") {
                viewModel.extractVideo()
            }
        case .failure(let error): Text("Error: \(String(describing: error))")
        case .loaded(let avPlayer):
            VideoPlayer(player: avPlayer)
                .frame(width: 200, height: 116)
        }
    }
}
