//
//  ConfigView.swift
//  Tritium
//
//  Created by Alexander Cyon on 2021-09-16.
//

import SwiftUI
import Makt

struct ConfigView: View {

    @Binding var config: Config?
    
    @State private  var resourcePath: String = Config.Directories.defaultGamesFilesDirectoryPath
    @State private var pathError: Swift.Error?

    var body: some View {
        VStack(spacing: 50) {
            Text("Path to original game resources (DATA, MAPS, MP3)")
            
            TextField("Resource path", text: $resourcePath)
            
            validationErrorView
            
            Button("Next") {
                let directories: Config.Directories = .init(resourcePath: resourcePath)
                do {
                    let newConfig = try Config(gamesFilesDirectories: directories, fileManager: .default)
                    self.config = newConfig
                } catch {
                    pathError = error
                }
            }
        }
    }
    
    var validationErrorView: some View {
        if let error = pathError {
            return Text("Error: \(String(describing: error))").eraseToAnyView()
        } else {
            return EmptyView().eraseToAnyView()
        }
    }
}
