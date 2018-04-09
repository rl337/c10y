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
    
    static func splitUInt64(_ value: UInt64) -> (UInt32, UInt32) {
        let part1 = UInt32(value & 0x00000000FFFFFFFF)
        let part2 = UInt32(value >> 32)
        return (part1, part2)
    }

    static func add(_ a: UInt32, _ b: UInt32) -> (UInt32, UInt32) {
        if UInt32.max - b >= a {
             return (a + b, 0)
        }
        
        if (a > b) {
            return (a - (UInt32.max - b) - 1, 1)
        }
        
        return (b - (UInt32.max - a) - 1, 1)
    }
    
    static func subtract(_ a: UInt32, _ b: UInt32) -> (UInt32, UInt32) {
        if b > a {
            return (UInt32.max - b + 1 + a, 1)
        }
        
        return (a - b, 0)
    }
    
    static func add_with_carry(_ value: UInt32, _ arr: inout [UInt32]) throws {
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
    
    static func add_with_carry(_ v: UInt32, _ slice: inout ArraySlice<UInt32>) throws {
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
    
    static func subtract_with_borrow(_ value: UInt32, _ arr: inout [UInt32]) throws {
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
    
    static func subtract_with_borrow(_ value: UInt32, _ slice: inout ArraySlice<UInt32>) throws {
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
