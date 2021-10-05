//
//  MapListView.swift
//  MapListView
//
//  Created by Alexander Cyon on 2021-09-22.
//

import SwiftUI
import Combine
import Makt

extension Map.ID: Identifiable {
    public typealias ID = String
    public var id: ID { self.fileName }
}

struct ErrorView: View {
    let error: Swift.Error
}
extension ErrorView {
    var body: some View {
        Text("Error: \(String(describing: error))")
    }
}

extension Map.BasicInformation {
    var versionEmoji: String {
        switch format {
        case .armageddonsBlade: return "🗡"
        case .restorationOfErathia: return "🛡"
        case .shadowOfDeath: return "💀"
        }
    }
}

struct MapListView: View {
    
    @ObservedObject var model: Model
    
    var body: some View {
        NavigationView {
            List {
                ForEach(Array(model.sizeToMaps.keys).sorted(by: \.tileCount)) { size in
                    Section(
                        header:
                            Text("Size: \(String(describing: size))")
                            .font(.largeTitle)
                    ) {
                        ForEach(model.sizeToMaps[size]!.sorted(by: \.name)) { basicMapInfo in
                            NavigationLink(destination: LoadMapView(
                                basicMapInfo: basicMapInfo,
                                assets: model.assets
                            ), label: {
                                HStack {
                                    Text(basicMapInfo.name)
                                    Spacer()
                                    Text(basicMapInfo.versionEmoji)
                                }
                                .lineLimit(1)
                                .font(.headline)
                            })
                        }
                    }
                }
            }
        }.padding()
    }
}

extension MapListView {
    final class Model: ObservableObject {
        
        private var cancellables = Set<AnyCancellable>()
        
        let assets: Assets
        let sizeToMaps: Dictionary<Size, [Map.BasicInformation]>
        
        init(assets: Assets) {
            self.assets = assets
            self.sizeToMaps =  .init(grouping: assets.basicInfoOfMaps, by: \.size)
        }
    }
}

extension Size: Identifiable {
    public typealias ID = Size.Scalar
    public var id: ID { width }
}
