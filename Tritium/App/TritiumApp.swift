//
//  TritiumApp.swift
//  Tritium
//
//  Created by Alexander Cyon on 2021-09-16.
//

import SwiftUI

@main
struct TritiumApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .fixedSize(horizontal: false, vertical: false)
                .frame(minWidth: 768, idealWidth: 1536, maxWidth: .infinity, minHeight: 480, idealHeight: 960, maxHeight: .infinity)
        }
    }
}
