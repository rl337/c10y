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

    static func add(_ a: UInt64, _ b: UInt64) -> (UInt64, UInt64) {
        if UInt64.max - b >= a {
             return (a + b, 0)
        }
        
        if (a > b) {
            return (a - (UInt64.max - b) - 1, 1)
        }
        
        return (b - (UInt64.max - a) - 1, 1)
    }
    
    static func subtract(_ a: UInt64, _ b: UInt64) -> (UInt64, UInt64) {
        if b > a {
            return (UInt64.max - b + 1 + a, 1)
        }
        
        return (a - b, 0)
    }
    
    static func add_with_carry(_ value: UInt64, _ arr: inout [UInt64]) throws {
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
    
    static func add_with_carry(_ v: UInt64, _ slice: inout ArraySlice<UInt64>) throws {
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
    
    static func subtract_with_borrow(_ value: UInt64, _ arr: inout [UInt64]) throws {
        var (v, b) = subtract(arr[0], value)
        arr[0] = v
        var i = 1
        while b > 0 {
            if i >= arr.count {
                throw BigintError.Underflow("Attempt to borrow beyond capacity from subtract operation")
            }
            
            (v, b) = subtract(arr[i], b)
            arr[i] = v
            i += 1
        }
    }
    
    static func subtract_with_borrow(_ value: UInt64, _ slice: inout ArraySlice<UInt64>) throws {
        var (v, b) = subtract(slice[slice.startIndex], value)
        slice[slice.startIndex] = v
        var i = 1
        while b > 0 {
            if i >= slice.endIndex {
                throw BigintError.Underflow("Attempt to borrow beyond capacity from subtract operation")
            }
            
            (v, b) = subtract(slice[i], b)
            slice[i] = v
            i += 1
        }
    }

}
