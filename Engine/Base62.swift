import Foundation

//
//  Base62.swift
//  Base62
//
//  Created by Sam Soffes on 5/20/16.
//  Copyright © 2016 Sam Soffes. All rights reserved.
//
import Darwin

class Base62{
    
    static let alphabet = [
        "0", "1", "2", "3", "4", "5", "6", "7", "8", "9",
        "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M",
        "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z",
        "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m",
        "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z",
        ]

    static func validUInt64Encoding(_ string: String) -> Bool {
        // String length of Base62 encoding UintN can be estimated by ceil(ln(2^N)/ln(62))
        let MAX_UINT64_ENCODED_STRING_LENGTH = 11
        
        if string.count > MAX_UINT64_ENCODED_STRING_LENGTH {
            return false
        }
        
        // Input string most only contain valid Base62 characters
        for c in string {
            guard let _ = alphabet.index(of: String(c)) else {
                return false
            }
        }
        
        // Now ensure encoded string won't overflow a UInt64
        do {
            var place: UInt64 = 1
            var result: UInt64 = 0
            
            for c in string.reversed() {
                // All characters in string are valid so indexOf is always valid
                let i = UInt64(Base62.alphabet.index(of: String(c))!)
                let (mulResult, mulOverflowed) = i.multipliedReportingOverflow(by: place)
                if mulOverflowed {
                    return false
                }
                let (addResult, addOverflowed) = result.addingReportingOverflow(mulResult)
                if addOverflowed {
                    return false
                }
                // Place is safe to overflow after last character
                place = place &* UInt64(62)
                result = addResult
            }
        }
        
        return true
    }

    static func encodeUInt64(_ integer: UInt64) -> String {
        let base = UInt64(alphabet.count)
        
        if integer < base {
            return alphabet[Int(integer)]
        }
        return encodeUInt64(integer / base) + alphabet[Int(integer % base)]
    }
    
    // !!!IMPORTANT!!! Only call on a validUInt64Encoding! Failure to comply
    // will result in undefined behaviour or runtime crashes!
    static func decodeUInt64(_ string: String) -> UInt64 {
        var place: UInt64 = 1
        var result: UInt64 = 0
        
        for c in string.reversed() {
            guard let i = alphabet.index(of: String(c)) else { continue }
            result += UInt64(i) * place
            // Place is safe to overflow here as can only occur on last character for valid input
            place = place &* UInt64(62)
        }
        
        return result
    }
}

class Base64{
    
    static let alphabet = [
        "0", "1", "2", "3", "4", "5", "6", "7", "8", "9",
        "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M",
        "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z",
        "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m",
        "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z",
        "+", "/"
        ]

    // String length of Base62 encoding UintN can be estimated by ceil(ln(2^N)/ln(64))
    static let MAX_UINT64_ENCODED_STRING_LENGTH = 11

    static func validUInt64Encoding(_ string: String) -> Bool {
        if string.count > MAX_UINT64_ENCODED_STRING_LENGTH {
            return false
        }
        
        // Input string most only contain valid Base62 characters
        for c in string {
            guard let _ = alphabet.index(of: String(c)) else {
                return false
            }
        }
        
        // Now ensure encoded string won't overflow a UInt64
        do {
            var place: UInt64 = 1
            var result: UInt64 = 0
            let base = UInt64(alphabet.count)
            for c in string.reversed() {
                // All characters in string are valid so indexOf is always valid
                let i = UInt64(alphabet.index(of: String(c))!)
                let (mulResult, mulOverflowed) = i.multipliedReportingOverflow(by: place)
                if mulOverflowed {
                    return false
                }
                let (addResult, addOverflowed) = result.addingReportingOverflow(mulResult)
                if addOverflowed {
                    return false
                }
                // Place is safe to overflow after last character
                place = place &* base
                result = addResult
            }
        }
        
        return true
    }
    
    static func encodeUInt64(_ integer: UInt64) -> String {
        let base = UInt64(alphabet.count)
        
        if integer < base {
            return alphabet[Int(integer)]
        }
        return encodeUInt64(integer / base) + alphabet[Int(integer % base)]
    }
    
    // !!!IMPORTANT!!! Only call on a validUInt64Encoding! Failure to comply
    // will result in undefined behaviour or runtime crashes!
    static func decodeUInt64(_ string: String) -> UInt64 {
        var place: UInt64 = 1
        var result: UInt64 = 0
        let base = UInt64(alphabet.count)
        
        for c in string.reversed() {
            guard let i = alphabet.index(of: String(c)) else { continue }
            result += UInt64(i) * place
            // Place is safe to overflow here as can only occur on last character for valid input
            place = place &* base
        }
        
        return result
    }
}
