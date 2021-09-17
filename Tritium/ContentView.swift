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
        
        let path = lodH3bitmap
        
        guard FileManager.default.fileExists(atPath: path) else {
            throw LoadAssetError(reason: "Path does not exist: \(path)")
        }

        guard let data = FileManager.default.contents(atPath: path) else {
            throw LoadAssetError(reason: "Failed to load data at path: \(path)")
        }
        
        return data
    }
    
    public static func load(callBack: @escaping (Result<(image: Image, name: String), LoadAssetError>) -> Void) {
        
        func imageFrom(data: Data) -> Image? {
            guard
                let nsImage = NSImage(data: data),
                case let image = Image(nsImage: nsImage) else {
                return nil
            }
            return image
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let lodDataRaw = try loadLODData()
                let lodParser = LodParser(data: lodDataRaw)
                let parsed = try lodParser.parse()
                let entries = parsed.entries
                guard !entries.isEmpty else {
                    callBack(.failure(LoadAssetError(reason: "No entries found.")))
                    return
                }
                let defFiles = entries.filter({ $0.kind == .pcx })
                let entry = defFiles[1]
                let content = entry.content
                switch content {
                case .pcxImage(let pcxImage):
                    assert(entry.kind == .pcx)
                    switch pcxImage.contents {
                    case .pixelData(let pixelData, let palette):
//                        fatalError("successfully loaded PCX pixeldata with palette")
                        let cgImage = imageFromPCX(pcxImage)
                        let image = Image.init(decorative: cgImage, scale: 1.0)
                        callBack(.success((image: image, name: entry.name)))
                    case .rawRGBPixelData(let pixelData):
                        guard let image = imageFrom(data: pixelData) else {
                            DispatchQueue.main.async {
                                callBack(.failure(LoadAssetError(reason: "Successfully loaded pcx raw image, but failed to init Image from it.")))
                            }
                            return
                        }
                        callBack(.success((image: image, name: entry.name)))
                    }
                case .dataEntry(let data):
                    assert(entry.kind != .pcx)
                    switch entry.kind {
                    case .def:
                       let defParser = DefParser(data: data)
                        let defFile = try defParser.parse()
                        let pixelData = defFile.blocks.first!.frames.first!.pixelData
                        guard let image = imageFrom(data: pixelData) else {
                            DispatchQueue.main.async {
                                callBack(.failure(LoadAssetError(reason: "Successfully loaded DEF File, but failed to init Image from it.")))
                            }
                            return
                        }
                        callBack(.success((image: image, name: entry.name)))
                    default:
                        guard let image = imageFrom(data: data) else {
                            DispatchQueue.main.async {
                                callBack(.failure(LoadAssetError(reason: "Successfully loaded dataEntry, but failed to init Image from it.")))
                            }
                            return
                        }
                        callBack(.success((image: image, name: entry.name)))
                    }
                    
    
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
    case loaded(Image, name: String)
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
                        case .success(let namedImage):
                            assetState = .loaded(namedImage.image, name: namedImage.name)
                        case .failure(let error):
                            assetState = .failed(error)
                        }
                    }
                }
            case .loaded(let imageLoaded, let imageName):
                VStack {
                    imageLoaded
                    Text("\(imageName)")
                }
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
