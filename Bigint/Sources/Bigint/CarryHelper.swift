//
//  CarryUnit.swift
//  Bigint
//
//  Created by Richard Lee on 3/18/18.
//

import Foundation

struct CarryHelper {
    
    private init() {
        
    }

    static public func add(_ a: UInt64, _ b: UInt64) -> (UInt64, UInt64) {
        if UInt64.max - b >= a {
             return (a + b, 0)
        }

        if UInt64.max == a {
            return (b, 1)
        }
        
        if UInt64.max == b {
            return (a, 1)
        }
        
        if (a > b) {
            return (a - (UInt64.max - b), 1)
        }
        
        return (b - (UInt64.max - a), 1)
    }
}
