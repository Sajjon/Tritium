//
//  ConfigView.swift
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

struct GameFilesView: View {
    let config: Config
    
    var body: some View {
        Text("Resource data: \(config.gamesFilesDirectories.data)")
    }
}

struct NavigationLazyView<Content: View>: View {
    let build: () -> Content
    init(_ build: @autoclosure @escaping () -> Content) {
        self.build = build
    }
    var body: Content {
        build()
    }
}


struct ContentView: View {
    @State var config: Config?
    
    var body: some View {
        if config == nil {
            ConfigView(config: $config)
        } else {
            Text("We've got the config: \(String(describing: config!.gamesFilesDirectories))")
        }
    }
}


struct ConfigView: View {
    
    
//    final class ViewModel: ObservableObject {
////        private var whenSetClosure: ((Bool) -> Void)?
//        @Published var config: Config?
////           { didSet {
////                if let setClosure = self.whenSetClosure {
////                    setClosure(self.config != nil)
////                }
////            }
////        }
////
////        init(_ config: Config? = nil, whenSetClosure: ((Bool) -> Void)? = nil) {
////            self.config = config
////            self.whenSetClosure = whenSetClosure
////        }
//    }
    
    @State var resourcePath: String = Config.Directories.defaultGamesFilesDirectoryPath
    
    @State var pathError: Swift.Error?
    @Binding var config: Config?
//    @ObservedObject var viewModel = ViewModel()

    var body: some View {
        VStack(spacing: 50) {
            Text("Path to original game resources (DATA, MAPS, MP3)")
            
            TextField("Resource path", text: $resourcePath)
            
//            validationErrorView
            
            Button("Next") {
                let directories: Config.Directories = .init(resourcePath: resourcePath)
                do {
                    let newConfig = try Config(gamesFilesDirectories: directories, fileManager: .default)
                    self.config = newConfig
//                    print("successfully created config!:\(config)")
                } catch {
                    pathError = error
                }
            }
           
//            NavigationLink(
//                destination: NavigationLazyView(GameFilesView(config: pathValidationStatus.config!)),
//                isActive: isGameFilesActive
//            ) { EmptyView() }
            
            if let error = pathError {
                Text("Error: \(String(describing: error))").eraseToAnyView()
            } else {
                NavigationLink(
                    destination: destination(),
                               isActive: .constant(config != nil)
                           ) { EmptyView() }
            }
            
        }
        .font(.largeTitle)
        .frame(width: 1024, height: 512)
    }
    
//    var validationErrorView: some View {
//        if let error = pathError {
//            return Text("Error: \(String(describing: error))").eraseToAnyView()
//        } else {
//            return EmptyView().eraseToAnyView()
//        }
//    }
    
    func destination() -> AnyView {
        if let config = config {
            return GameFilesView(config: config).eraseToAnyView()
        } else {
            return EmptyView().eraseToAnyView()
        }
    }
}

struct ConfigView_Previews: PreviewProvider {
    static var previews: some View {
        ConfigView(config: .constant(nil))
    }
}

extension View {
    func eraseToAnyView() -> AnyView {
        AnyView(self)
    }
}
