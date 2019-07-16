//
//  Data+Array.swift
//  SDRControls
//
//  Created by Davorin Madaric on 06/07/2019.
//  Copyright © 2019 Davorin Madaric. All rights reserved.
//

import Foundation

extension Data {
    init<T>(fromArray values: [T]) {
        var values = values
        self.init(buffer: UnsafeBufferPointer(start: &values, count: values.count))
    }
    
    func toArray<T>(type: T.Type) -> [T] {
        let value = self.withUnsafeBytes {
            $0.baseAddress?.assumingMemoryBound(to: T.self)
        }
        return [T](UnsafeBufferPointer(start: value, count: self.count / MemoryLayout<T>.stride))
    }
    
}
