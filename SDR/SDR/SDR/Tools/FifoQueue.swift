//
//  FifoQueue.swift
//  ImpactWrapConsumer
//
//  Created by Miha Hozjan on 11/01/2018.
//  Copyright © 2018 Inova. All rights reserved.
//

import Foundation

class FifoQueue<T: Any> {
    private(set) var elements: [T]
    private let size: Int
    
    init(size: Int) {
        self.elements = [T]()
        self.size = size
    }
    
    func push(elt: T) {
        elements.append(elt)
        
        if elements.count > size { _ = elements.removeFirst() }
    }
    
    func removeAll() {
        elements.removeAll()
    }
}
