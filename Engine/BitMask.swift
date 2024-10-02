//
//  BitSet.swift
//  Engine
//
//  Created by Powley, Edward on 16/10/2015.
//  Copyright © 2015 Simon Colton. All rights reserved.
//

import Foundation

class BitMask {
    
    var mask: UInt32
    
    init(mask: UInt32) {
        self.mask = mask
    }
    
    init(singleton: Int) {
        assert(singleton >= 0 && singleton < 32, "index must be in 0...31")
        self.mask = UInt32(1) << UInt32(singleton)
    }
    
    init(elements: Int...) {
        self.mask = 0
        for index in elements {
            assert(index >= 0 && index < 32, "index must be in 0...31")
            self.mask |= UInt32(1) << UInt32(index)
        }
    }
    
    init(rangeFrom: Int, rangeToExc: Int) {
        self.mask = 0
        for index in rangeFrom ..< rangeToExc {
            assert(index >= 0 && index < 32, "index must be in 0...31")
            self.mask |= UInt32(1) << UInt32(index)
        }
    }
    
    init(rangeFrom: Int, rangeToInc: Int) {
        self.mask = 0
        for index in rangeFrom ... rangeToInc {
            assert(index >= 0 && index < 32, "index must be in 0...31")
            self.mask |= UInt32(1) << UInt32(index)
        }
    }
    
    var isSingleton: Bool {
        // https://graphics.stanford.edu/~seander/bithacks.html#DetermineIfPowerOf2
        return mask != 0 && (mask & (mask - 1)) == 0
    }
    
    static let zero = BitMask(mask: 0)
    static let everything = BitMask(mask: 0xFFFFFFFF)
}

/// Union
func +(a: BitMask, b: BitMask) -> BitMask {
    return BitMask(mask: a.mask | b.mask)
}

/// Difference
func -(a: BitMask, b: BitMask) -> BitMask {
    return BitMask(mask: a.mask & ~b.mask)
}

