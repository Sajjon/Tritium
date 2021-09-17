////
////  AssetLoader.swift
////  AssetLoader
////
////  Created by Alexander Cyon on 2021-09-17.
////
//
//import Foundation
//import SwiftUI
//import Guld
//
//final class AssetLoader {
//    init() {}
//}
//
//extension AssetLoader {
//
//    func load(
//        assetPath: String,
//        callBack: @escaping (Result<(image: Image, name: String), LoadAssetError>) -> Void
//    ) {
//
//
//        let
//
//        func imageFrom(data: Data) -> Image? {
//            guard
//                let nsImage = NSImage(data: data),
//                case let image = Image(nsImage: nsImage) else {
//                return nil
//            }
//            return image
//        }
//
//        DispatchQueue.global(qos: .userInitiated).async {
//            do {
//                let lodDataRaw = try loadLODData()
//                let lodParser = LodParser(data: lodDataRaw)
//                let parsed = try lodParser.parse()
//                let entries = parsed.entries
//                guard !entries.isEmpty else {
//                    callBack(.failure(LoadAssetError(reason: "No entries found.")))
//                    return
//                }
//                let defFiles = entries.filter({ $0.kind == .pcx })
//                let entry = defFiles[1]
//                let content = entry.content
//                switch content {
//                case .pcxImage(let pcxImage):
//                    assert(entry.kind == .pcx)
//                    switch pcxImage.contents {
//                    case .pixelData(let pixelData, let palette):
//                        let cgImage = imageFromPCX(pcxImage)
//                        let image = Image.init(decorative: cgImage, scale: 1.0)
//                        callBack(.success((image: image, name: entry.name)))
//                    case .rawRGBPixelData(let pixelData):
//                        guard let image = imageFrom(data: pixelData) else {
//                            DispatchQueue.main.async {
//                                callBack(.failure(LoadAssetError(reason: "Successfully loaded pcx raw image, but failed to init Image from it.")))
//                            }
//                            return
//                        }
//                        callBack(.success((image: image, name: entry.name)))
//                    }
//                case .dataEntry(let data):
//                    assert(entry.kind != .pcx)
//                    switch entry.kind {
//                    case .def:
//                       let defParser = DefParser(data: data)
//                        let defFile = try defParser.parse()
//                        let pixelData = defFile.blocks.first!.frames.first!.pixelData
//                        guard let image = imageFrom(data: pixelData) else {
//                            DispatchQueue.main.async {
//                                callBack(.failure(LoadAssetError(reason: "Successfully loaded DEF File, but failed to init Image from it.")))
//                            }
//                            return
//                        }
//                        callBack(.success((image: image, name: entry.name)))
//                    default:
//                        guard let image = imageFrom(data: data) else {
//                            DispatchQueue.main.async {
//                                callBack(.failure(LoadAssetError(reason: "Successfully loaded dataEntry, but failed to init Image from it.")))
//                            }
//                            return
//                        }
//                        callBack(.success((image: image, name: entry.name)))
//                    }
//
//
//                }
//
//            } catch {
//                DispatchQueue.main.async {
//                    callBack(.failure(LoadAssetError(reason: error.localizedDescription)))
//                }
//            }
//        }
//    }
//}
//
//enum AssetState: Equatable {
//    case initialized
//    case loading
//    case loaded(Image, name: String)
//    case failed(LoadAssetError)
//}
//
//struct LoadAssetError: Swift.Error, Hashable, CustomStringConvertible {
//    let reason: String
//    var description: String { reason }
//}
