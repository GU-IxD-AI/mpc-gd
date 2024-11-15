//
//  ArrayUtils.swift
//  Beeee
//
//  Created by Powley, Edward on 03/09/2015.
//  Copyright (c) 2018 ThoseMetamakers. All rights reserved.
//

import Foundation
import SpriteKit

class ArrayUtils {
    
    static func create2DArray<T>(width: Int, height: Int, initial: T) -> [[T]] {
        return Array(repeating: Array(repeating: initial, count: height), count: width)
    }
    
    struct PixelData {

        var a: UInt8 = 0
        var r: UInt8 = 0
        var g: UInt8 = 0
        var b: UInt8 = 0
        
        init(a: UInt8, r: UInt8, g: UInt8, b: UInt8) {
            self.a = a
            self.r = r
            self.g = g
            self.b = b
        }
        
        init(colour : UIColor) {
            var fa: CGFloat = 0
            var fr: CGFloat = 0
            var fg: CGFloat = 0
            var fb: CGFloat = 0
            
            colour.getRed(&fr, green: &fg, blue: &fb, alpha: &fa)
            
            self.a = UInt8(fa * 255.0)
            self.r = UInt8(fr * 255.0)
            self.g = UInt8(fg * 255.0)
            self.b = UInt8(fb * 255.0)
        }
    }
        
}
