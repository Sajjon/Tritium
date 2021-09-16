//
//  ContentView.swift
//  Tritium
//
//  Created by Alexander Cyon on 2021-09-16.
//

import SwiftUI

import Makt

private final class ImageLoader {

    private static func loadLODData() throws -> Data {
        let dataPath = "/Users/sajjon/Library/Application Support/HoMM3SwiftUI/Data/"
        let lodH3sprite = dataPath.appending("H3sprite.lod")
        let lodH3bitmap = dataPath.appending("H3bitmap.lod")
        let lodH3ab_spr = dataPath.appending("H3ab_spr.lod")
        let lodH3ab_bmp = dataPath.appending("H3ab_bmp.lod")
        
        let path = lodH3sprite
        
        print("trying to read LOD file at path: \(path)")
        
        guard FileManager.default.fileExists(atPath: path) else {
            throw LoadAssetError(reason: "Path does not exist: \(path)")
        }

        guard let data = FileManager.default.contents(atPath: path) else {
            let error = LoadAssetError(reason: "Failed to load data at path: \(path)")
            print("☣️ error: \(error)")
            throw error
        }
        
        print("✅ successfully loaded LOD file at path: \(path)")
        
        return data
    }
    
    public static func load(callBack: @escaping (Result<Image, LoadAssetError>) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let data = try loadLODData()
                let lodParser = LodParser(data: data)
                print("initialized LOD parser")
                let parsed = try lodParser.parse()
                let entries = parsed.entries
                guard let entry = entries.first else {
                    callBack(.failure(LoadAssetError(reason: "No entries found.")))
                    return
                }
                
                let content = entry.content
                switch content {
                case .pcxImage(let pcxImage):
                    switch pcxImage.contents {
                    case .pixelData(let pixelData, let palette):
                        fatalError("successfully loaded PCX pixeldata with palette")
                    case .rawRGBPixelData(let pixelData):
                        guard
                            let nsImage = NSImage(data: pixelData),
                            case let image = Image(nsImage: nsImage) else {
                            DispatchQueue.main.async {
                                callBack(.failure(LoadAssetError(reason: "Successfully loaded pcx raw image, but failed to init NSImage from it.")))
                            }
                            return
                        }
                        callBack(.success(image))
                    }
                case .dataEntry(let data):
                    fatalError("successfully loaded data entry in LOD")
                }
           
            } catch {
                DispatchQueue.main.async {
                    callBack(.failure(LoadAssetError(reason: error.localizedDescription)))
                }
            }
        }
    }
}

enum AssetState: Equatable {
    case initialized
    case loading
    case loaded(Image)
    case failed(LoadAssetError)
}

struct LoadAssetError: Swift.Error, Hashable, CustomStringConvertible {
    let reason: String
    var description: String { reason }
}

struct ContentView: View {
    
 
    
    @State var assetState: AssetState = .initialized
    
    var body: some View {
        Group {
            switch assetState {
            case .initialized:
                Button("Load asset now") {
                    defer { assetState = .loading }
                    ImageLoader.load { result in
                        switch result {
                        case .success(let image):
                            assetState = .loaded(image)
                        case .failure(let error):
                            assetState = .failed(error)
                        }
                    }
                }
            case .loaded:
                Text("Loaded")
            case .loading:
                Text("Loading")
            case .failed(let error):
                Text("Erorr: \(String(describing: error))")
            }
        }
        .font(.largeTitle)
        .frame(width: 512, height: 512)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
