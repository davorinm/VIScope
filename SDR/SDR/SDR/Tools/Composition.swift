//
//  Composition.swift
//  SDR
//
//  Created by Davorin Madaric on 07/05/2019.
//  Copyright © 2019 Davorin Madaric. All rights reserved.
//

import Foundation

infix operator --> :AdditionPrecedence

func --> <A, B, C> (aToB: @escaping (A) -> B, bToC: @escaping (B) -> C) -> (A) -> C {
    return { a in
        let b = aToB(a)
        let c = bToC(b)
        return c
    }
}


class Composition {
    
    // TODO: Implement
    func add<A, B, C>(aToB: @escaping ((A) -> B), bToC: @escaping ((B) -> C)) -> ((A) -> C) {
        
        
        
        return { a in
            let b = aToB(a)
            let c = bToC(b)
            return c
        }
    }
    
    
    
}
