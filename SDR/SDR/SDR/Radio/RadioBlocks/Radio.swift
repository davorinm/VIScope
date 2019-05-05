//
//  Radio.swift
//  SDR
//
//  Created by Davorin Mađarić on 24/04/2019.
//  Copyright © 2019 Davorin Madaric. All rights reserved.
//

import Foundation

class Radio {
    private let processQueue: DispatchQueue = DispatchQueue(label: "Radio")
    
    private var blocks: [RadioBlock] = []
    
    func addBlock(_ radioBlock: RadioBlock) {
        blocks.append(radioBlock)
        
//        radioBlock.queue = processQueue
//        radioBlock.completionBlock = {
//            
//        }
//        
//        if let previousRadioBlock = blocks.last {
//            radioBlock.addDependency(previousRadioBlock)
//        }
//        
//        blocks.append(radioBlock)
        
        
        
        
        let f = Future<([UInt8])> { comp in
            
            
            
            comp(Promise.success(()))
        }
    }
    
    func samplesIn(_ rawSamples: [UInt8]) {
        processQueue.async { [unowned self] in
        
            for block in self.blocks {
                block.samplesIn(<#T##samplesIn: [Int]##[Int]#>, <#T##samplesOut: ((SDRSamples) -> Void)##((SDRSamples) -> Void)##(SDRSamples) -> Void#>)
                
                
                
            }
            
            
            
            
            
            
        }
    }
}
