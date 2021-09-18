
import Foundation
import CoreGraphics
import Guld
import Combine
import Util

// MARK: ImageLoader
final class ImageLoader {
    init() {}
}

// MARK: Error
extension ImageLoader {
    enum Error: Swift.Error {
        case failedToCreateImageContext
//        case failedToCreateImageFromData
        case failedToCreateImageFromContext
    }
}

import CoreImage

// MARK: To CGImage
extension ImageLoader {
    
    private func pixelsFrom(data pixelData: Data) -> [UInt32] {
        let bytesPerPixel = 3
        assert(pixelData.count.isMultiple(of: bytesPerPixel))
        let pixels: [UInt32] = Array<UInt8>(pixelData).chunked(into: bytesPerPixel).map { (chunk: [UInt8]) -> UInt32 in
            assert(chunk.count == bytesPerPixel)
            var data = Data()
            data.append(chunk[2]) // red
            data.append(chunk[1]) // green
            data.append(chunk[0]) // blue
            data.append(255) // Alpha of 255
            data.reverse() // fix endianess
            return data.withUnsafeBytes { $0.load(as: UInt32.self) }
        }
        return pixels
    }

    private static func convertCIImageToCGImage(inputImage: CIImage) -> CGImage? {
        let context = CIContext(options: nil)
        if let cgImage = context.createCGImage(inputImage, from: inputImage.extent) {
            return cgImage
        }
        return nil
    }
  
    
    func loadImageFrom(data: Data) -> AnyPublisher<CGImage, Error> {
        guard let ciImage = CIImage.init(data: data) else {
            fatalError("No luck createing CIImage from Data")
        }
        guard let cgImage = ImageLoader.convertCIImageToCGImage(inputImage: ciImage) else {
            fatalError("no luck converting CIImage to CGImage")
        }
        return Just(cgImage)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    func loadImageFrom(
        pcx: PCXImage
    ) -> AnyPublisher<CGImage, Error> {
        
        let pixelData: Data
        var maybePalette: Palette?
        switch pcx.contents {
        case .pixelData(let data, encodedByPalette: let palette):
            pixelData = data
            maybePalette = palette
        case .rawRGBPixelData(let data):
            pixelData = data
        }
        
        return Future { promise in
            DispatchQueue(label: "ImageLoader", qos: .background).async { [self] in
                do {
                    
                    let pixels: [UInt32] = {
                        if let palette = maybePalette {
                            let palette32Bit = palette.toU32Array()
                            
                            let pixels: [UInt32] = pixelData.map {
                                palette32Bit[Int($0)]
                            }
                            return pixels
                        } else {
                           return pixelsFrom(data: pixelData)
                        }
                    }()
                   
                    let pixelMatrix = pixels.chunked(into: pcx.width)
                   
                    let cgImage = try makeCGImage(pixelValueMatrix: pixelMatrix)
                    
                    promise(Result.success(cgImage))
                    
                } catch let error as Error {
                    promise(Result.failure(error))
                } catch { uncaught(error: error, expectedType: Error.self) }
            }
        }.eraseToAnyPublisher()
    }
}

// MARK: Private
private extension ImageLoader {
    func makeCGImage(pixelValueMatrix: [[UInt32]]) throws -> CGImage {
        guard let ctx = CGContext.from(pixels: pixelValueMatrix) else {
            throw Error.failedToCreateImageContext
        }
        guard let cgImage = ctx.makeImage() else {
            throw Error.failedToCreateImageFromContext
        }
        return cgImage
    }

}
