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
//            switch model.state {
//            case .idle:
//                Button("Load maps") {
//                    model.load()
//                }
//            case .failure(let error):
//                ErrorView(error: error)
//            case .loading:
//                Text("Loading map ids...")
//            case .loaded(let basicInfoForMaps):
            
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
                .frame(minWidth: 300, idealWidth: 500, alignment: .leading)
//            }
        }
    }
}

extension MapListView {
    final class Model: ObservableObject {
//        @Published var state: LoadingState<[Map.BasicInformation]> = .idle
        
        private var cancellables = Set<AnyCancellable>()
        
        let assets: Assets
//        var basicInfoForMaps: [Map.BasicInformation] { assets.basicInfoOfMaps }
        let sizeToMaps: Dictionary<Size, [Map.BasicInformation]>
        
        init(assets: Assets) {
            self.assets = assets
            self.sizeToMaps =  .init(grouping: assets.basicInfoOfMaps, by: \.size)
        }
    }
}

//extension MapListView.Model {
//    func load() {
//
//        state = .loading(progress: nil)
//
//        assets.loadBasicInfoForAllMaps()
//            .receive(on: RunLoop.main)
//            .sink(receiveValue: { [self] basicInfoForMaps in
//                    state = .loaded(basicInfoForMaps)
//                }
//            ).store(in: &cancellables)
//    }
//}

extension Size: Identifiable {
    public typealias ID = Size.Scalar
    public var id: ID { width }
}
