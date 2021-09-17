//
//  CGImageTools.swift
//  CGImageTools
//
//  Created by Alexander Cyon on 2021-09-17.
//

import Foundation
import CoreGraphics

extension CGContext {
    private static let colorSpace = CGColorSpaceCreateDeviceRGB()

    private static let bitmapInfo =
        CGBitmapInfo.byteOrder32Little.rawValue |
        CGImageAlphaInfo.premultipliedLast.rawValue & CGBitmapInfo.alphaInfoMask.rawValue

    static func from(pixels pixelMatrix: [[UInt32]]) -> CGContext? {
        let width = pixelMatrix.first?.count ?? 0
        let height = pixelMatrix.count
        assert(pixelMatrix.allSatisfy { $0.count == width })
        let pixels: [UInt32] = pixelMatrix.flatMap { $0 }
        var mutPixels = pixels

        let bitsPerByte = UInt8.bitWidth
        let bytesPerPixel = UInt32.bitWidth / bitsPerByte
        let bytesPerRow = width * bytesPerPixel

        return CGContext(
            data: &mutPixels,
            width: width,
            height: height,
            bitsPerComponent: bitsPerByte,
            bytesPerRow: bytesPerRow,
            space: colorSpace,
            bitmapInfo: bitmapInfo,
            releaseCallback: nil,
            releaseInfo: nil
        )
    }
}

public extension CGImage {
    
    enum Error: Swift.Error {
        case failedToCreateImageFromData
    }
//
//    /// https://gist.github.com/palmerc/a626b447c62f472dbae6
//    static func fromPixelData(
//        _ pixelData: Data,
//        width: Int,
//        height: Int
//    ) throws -> CGImage {
//
//        let colorSpaceRef = CGColorSpaceCreateDeviceGray()
//
//        let bitsPerComponent = 8
//        let bytesPerPixel = 1
//        let bitsPerPixel = bytesPerPixel * bitsPerComponent
//        let bytesPerRow = bytesPerPixel * width
//        let totalBytes = height * bytesPerRow
//
//        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.none.rawValue).union([])
//
//        var data = pixelData
////
//        let providerRef = data.withUnsafeMutableBytes {
//            let providerRef = CGDataProviderCreateWithData(nil, $0.baseAddress, totalBytes, nil)
//            return
//        }
//
////        let imageDataPointer = UnsafeMutablePointer<UInt8>(data)
//
//
////        let providerRef = CGDataProvider.init(data: data)
//
//
////        let imageRef = CGImageCreate(
////            width,
////            height,
////            bitsPerComponent,
////            bitsPerPixel,
////            bytesPerRow,
////            colorSpaceRef,
////            bitmapInfo,
////            providerRef,
////            nil,
////            false,
////            CGColorRenderingIntent.RenderingIntentDefault)
////
//
////        return imageRef
//        fatalError()
//    }

}

extension Palette {
    func toU32Array() -> [UInt32] {
        colors.enumerated().map { i, color in
            var data = Data()
            data.append(color.red)
            data.append(color.green)
            data.append(color.blue)
            data.append(255) // alpha
            data.reverse() // fix endianess
            return data.withUnsafeBytes { $0.load(as: UInt32.self) }
        }
    }
}

private func makeCGImage(pixelValueMatrix: [[UInt32]]) -> CGImage {
  
    guard let ctx = CGContext.from(pixels: pixelValueMatrix) else { fatalError("no context") }
    guard let cgImage = ctx.makeImage() else { fatalError("no image") }
    return cgImage
}

import Guld
func imageFromPCX(
    _ pcx: PCXImage
) -> CGImage {
    
    let pixelData: Data
    var maybePalette: Palette?
    switch pcx.contents {
    case .pixelData(let data, encodedByPalette: let palette):
        pixelData = data
        maybePalette = palette
    case .rawRGBPixelData(let data):
        pixelData = data
    }
    
    guard let palette = maybePalette else {
        fatalError("no palette")
    }
    
    let palette32Bit = palette.toU32Array()

    let pixels: [UInt32] = pixelData.map {
        palette32Bit[Int($0)]
        
    }
    let pixelMatrix = pixels.chunked(into: pcx.width)
    return makeCGImage(pixelValueMatrix: pixelMatrix)
}
