//
//  DataExtensions.swift
//  PocketWizard
//
//  Created by Bryce Kowalczyk on 7/22/20.
//  Copyright © 2020 Bryce Kowalczyk. All rights reserved.
//

import Foundation

extension Data {
    
    var stringUTF8Encoded: String? {
        get {
            return String(data: self, encoding: .utf8) as String?
        }
    }
    
    var uInt8Array: [UInt8]? {
        get {
            var uInt8Array = [UInt8](repeating: 0, count: self.count)
            self.copyBytes(to: &uInt8Array, count: self.count * MemoryLayout<UInt8>.size)
            return uInt8Array
        }
    }
}
