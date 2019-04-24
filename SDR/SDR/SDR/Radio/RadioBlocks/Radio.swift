//
//  Radio.swift
//  SDR
//
//  Created by Davorin Mađarić on 24/04/2019.
//  Copyright © 2019 Davorin Madaric. All rights reserved.
//

import Foundation

class Radio {
    private lazy var processQueue: OperationQueue = {
        var queue = OperationQueue()
        queue.name = "Radio Process Queue"
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
    
    private var blocks: [RadioBlock] = []
    
    func addBlock(_ radioBlock: RadioBlock) {
        radioBlock.queue = processQueue
        radioBlock.completionBlock = {
            
        }
        
        if let previousRadioBlock = blocks.last {
            radioBlock.addDependency(previousRadioBlock)
        }
        
        blocks.append(radioBlock)
    }
    
    func samplesIn(_ rawSamples: [UInt8]) {
        
    }
}
