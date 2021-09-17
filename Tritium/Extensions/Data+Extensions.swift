//
//  Data+Extensions.swift
//  Data+Extensions
//
//  Created by Alexander Cyon on 2021-09-17.
//

import Foundation

extension Data {
    var sizeString: String {
        let bytes = count
        if bytes >= .mega {
            return "\(megabytes) mb"
        }
        if bytes >= .kilo {
            return "\(kilobytes) kb"
        }
        
        return "\(bytes) bytes"
    }
    
    var megabytes: Int {
        count / .mega
    }
    
    var kilobytes: Int {
        count / .kilo
    }
}

extension Int {
    
    static let mega: Self = Self.kilo * .kilo
    static let kilo: Self = 1_000

}
