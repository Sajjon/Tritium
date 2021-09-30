//
//  LoadingState.swift
//  Tritium
//
//  Created by Alexander Cyon on 2021-09-30.
//

import Foundation
import Makt

enum LoadingState<Model> {
    case idle
    case loading(progress: LoadingProgress? = nil)
    case loaded(Model)
    case failure(Swift.Error)
    
    var isLoaded: Bool {
        switch self {
        case .loaded: return true
        case .loading, .idle, .failure: return false
        }
    }
}
