//
//  DebugTileView.swift
//  Tritium
//
//  Created by Alexander Cyon on 2021-09-30.
//

import SwiftUI
import Makt
import Combine


struct DebugTileView: View {
    @Environment(\.presentationMode) var presentationMode
   
    let tile: ProcessedMap.Tile
    let onDismiss: () -> Void
    
    var body: some View {
        VStack {
            Text("Debugging tile @: \(String(describing: tile.position))")
                .font(.title)
            Text(String(describing: tile.mapTile))
                .font(.body)
            
            HStack {
                ForEach(tile.images) { image in
                    VStack {
                        Text("\(image.hint)")
                            .font(.subheadline)
                            .contextMenu(ContextMenu(menuItems: { // TODO after macos 12.0, use `textSelection(.enabled)`
                                Button("Copy sprite name", action: {
                                    NSPasteboard.general.setString(image.hint, forType: .string)
                                })
                            })).background(Color.black)
                        
                        Image(decorative: image.cgImage, scale: 1)
                            .offset(x: -image.image.rect.origin.x, y: -image.image.rect.origin.y)
                    }
                }
            }  .background(Chessboard().fill(Color.chessboardGrey))
            
            Button("Press to dismiss") {
                onDismiss()
                presentationMode.wrappedValue.dismiss()
            }
            .font(.callout)
        }
        .frame(minWidth: 1000, minHeight: 800)
        .padding()
    }
    
}

// MARK: Chessboard

/// Typically used as background for images with alpha.
struct Chessboard: Shape {
    
    static let squareSize = 4

    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let rowSize = Self.squareSize
        let columnSize = Self.squareSize

        let rows = Int(rect.height) / rowSize
        let columns = Int(rect.width) / columnSize

        for row in 0 ..< rows {
            for column in 0 ..< columns {
                guard (row + column).isMultiple(of: 2) else { continue }
               
                let startX = CGFloat(columnSize * column)
                let startY = CGFloat(rowSize * row)
                
                let rect = CGRect(x: startX, y: startY, width: .init(columnSize), height: .init(rowSize))
                path.addRect(rect)
            }
        }

        return path
    }
}

extension Color {
    static let chessboardGrey = Self(red: 192/255, green: 192/255, blue: 192/255)
}
