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
        
        if (a > b) {
            return (a - (UInt64.max - b) - 1, 1)
        }
        
        return (b - (UInt64.max - a) - 1, 1)
    }
    
    static public func add_with_carry(_ value: UInt64, _ arr: inout [UInt64]) throws {
        var (v, c) = add(value, arr[0])
        arr[0] = v
        var i = 1
        while c > 0 {
            if i >= arr.count {
                throw BigintError.Overflow("Attempt to carry beyond capacity from add operation")
            }
            
            (v, c) = add(c, arr[i])
            arr[i] = v
            i += 1
        }
    }
    
    static public func add_with_carry(_ v: UInt64, _ slice: inout ArraySlice<UInt64>) throws {
        var (v, c) = add(v, slice[slice.startIndex])
        slice[slice.startIndex] = v
        var i = slice.startIndex + 1
        while c > 0 {
            if i >= slice.endIndex {
                throw BigintError.Overflow("Attempt to carry beyond capacity from add operation")
            }
            
            (v, c) = add(c, slice[i])
            slice[i] = v
            i += 1
        }
    }
}
