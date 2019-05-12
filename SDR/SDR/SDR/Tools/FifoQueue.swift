//
//  FifoQueue.swift
//  ImpactWrapConsumer
//
//  Created by Miha Hozjan on 11/01/2018.
//  Copyright © 2018 Inova. All rights reserved.
//

import Foundation

class FifoQueue<T: Any> {
    private var elements: [T]
    private let size: Int
    var count: Int {
        get {
            return self.elements.count
        }
    }
    
    init(size: Int) {
        self.elements = [T]()
        self.elements.reserveCapacity(size)
        
        self.size = size
    }
    
    func push(_ elt: T) {
        elements.append(elt)
        
        if elements.count > size {
            _ = elements.removeFirst()
        }
    }
    
    func push(_ elt: [T]) {
        elements.append(contentsOf: elt)
        
        // TODO: FIX
//        if elements.count > size {
//            _ = elements.removeFirst()
//        }
    }
    
    func pop(_ first: Int) -> [T]? {
        guard elements.count >= first else {
            return nil
        }
        
        defer {
            elements.removeFirst(first)
        }
        
        return Array(elements.prefix(first))
    }
    
    func removeAll() {
        elements.removeAll()
    }
}
