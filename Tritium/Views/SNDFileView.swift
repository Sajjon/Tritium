//
//  SNDFileView.swift
//  SNDFileView
//
//  Created by Alexander Cyon on 2021-09-20.
//

import Foundation
import SwiftUI
import Guld
import AVFoundation

struct SNDFileView: View {
    let sndFile: SNDFile
    var body: some View {
        VStack {
            Text("SND File: \(sndFile.sndArchiveFileName)")
            List(sndFile.fileEntries, id: \.self) { soundFile in
                SoundFileView(soundFile: soundFile)
            }
        }
    }
}


struct SoundFileView: View {
    let soundFile: SNDFile.FileEntry
    
    func loadSoundFileResult() -> Result<AVAudioPlayer, Swift.Error> {
        do {
            // IMPORTANT: For more advanced playback capabilities, use: AVAudioEngine
            // https://developer.apple.com/documentation/avfaudio/avaudioengine
            let audioPlayer = try AVAudioPlayer(
                data: soundFile.contents,
                fileTypeHint: soundFile.fileExtension
            )
            return .success(audioPlayer)
        } catch {
            return .failure(error)
        }
    }
    
    var body: some View {
        VStack {
            Text("Name: \(soundFile.fileName) - #\(soundFile.contents.sizeString)")
            switch loadSoundFileResult() {
            case .success(let audioPlayer):
                    Button("Play sound") {
                        audioPlayer.play()
                    }
            case .failure(let error):
                Text("Failed to load audio, error: \(String(describing: error))")
            }
            
            
        }
    }
}
