//
//  OperationTest.swift
//  ViScope
//
//  Created by Davorin Mađarić on 07/05/2019.
//  Copyright © 2019 Davorin Mađarić. All rights reserved.
//

import Foundation

class Operation1 {
    func process(data: [UInt8]) -> [UInt8] {
        return data.map { $0 + 1 }
    }
}

class Operation2 {
    func process(data: [UInt8]) -> [UInt8] {
        return data.map { $0 + 1 }
    }
}

class Operation3 {
    func process(data: [UInt8]) -> [UInt8] {
        return data.map { $0 + 1 }
    }
}

class Operation4 {
    func process(data: [UInt8]) -> [UInt8] {
        return data.map { $0 + 1 }
    }
}

class OperationTest {
    func run() {
        let op1 = Operation1()
        let op2 = Operation2()
        let op3 = Operation3()
        let op4 = Operation4()
        
        let input = Future<[UInt8]> { completion in
            let data: [UInt8] = [1, 2, 3, 4, 5]
            completion(.success(data))
        }
        
        let chain = input.then(op1.process)
            .then(op2.process)
            .then(op3.process)
            .then(op4.process)
        
        chain.done { (result) in
            switch result {
            case .success(let data):
                print(data)
                break
            case .failure(let error):
                print(error)
                break
            }
        }
    }
