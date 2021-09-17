//
//  View+Extension.swift
//  View+Extension
//
//  Created by Alexander Cyon on 2021-09-17.
//

import Foundation
import SwiftUI

extension View {
    func eraseToAnyView() -> AnyView {
        AnyView(self)
    }
}
