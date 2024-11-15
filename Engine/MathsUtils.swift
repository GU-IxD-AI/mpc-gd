//
//  MathsUtils.swift
//  Fask
//
//  Created by Powley, Edward on 01/10/2015.
//  Copyright © 2018 ThoseMetamakers. All rights reserved.
//

import Foundation
import SpriteKit

class MathsUtils {
    
    static let π = CGFloat.pi
    
    /// Get the number of decimal places required to approximately represent the given number
    static func requiredDecimals(_ x: CGFloat) -> Int {
        var decimals : Int = 0
        while decimals < 10 {
            let powerOfTen = pow(CGFloat(10.0), CGFloat(decimals))
            // powerOfTen goes 1, 10, 100, 1000, ...
            
            let rx = round(x * powerOfTen) / powerOfTen
            // rx is x rounded to the nearest (1/powerOfTen) step
            
            if x.approxEquals(rx) {
                return decimals
            }
            decimals += 1
        }
        return decimals
    }
    
    /// Clamp x to be between min and max
    static func clamp<T : Comparable>(_ x: T, min: T, max: T) -> T {
        if x < min {
            return min
        }
        else if x > max {
            return max
        }
        else {
            return x
        }
    }
    
    /// Linearly interpolate between n0 and n1, according to p in the range 0...1
    static func lerp(_ p: CGFloat, n0: CGFloat, n1: CGFloat) -> CGFloat {
        return n0 * (1-p) + n1 * p
    }
    
    /// Linearly interpolate between n0 and n1, according to p in the range 0...1
    static func lerp(_ p: CGFloat, p0: CGPoint, p1: CGPoint) -> CGPoint {
        return CGPoint(x: lerp(p, n0: p0.x, n1: p1.x), y: lerp(p, n0: p0.y, n1: p1.y))
    }
    
    static func lerp(_ p: CGFloat, c0: UIColor, c1: UIColor) -> UIColor {
        let (r0,g0,b0,a0) = c0.getRGBA()
        let (r1,g1,b1,a1) = c1.getRGBA()
        return UIColor(red: lerp(p, n0: r0, n1: r1),
                       green: lerp(p, n0: g0, n1: g1),
                       blue: lerp(p, n0: b0, n1: b1),
                       alpha: lerp(p, n0: a0, n1: a1))
    }
    
    static func degreesToRadians(_ angle: CGFloat) -> CGFloat {
        return angle / 180.0 * π
    }
    
    static func radiansToDegrees(_ angle: CGFloat) -> CGFloat {
        return angle * 180.0 / π
    }
    
    static func sign(_ x: CGFloat) -> CGFloat {
        if x < 0 {
            return -1
        }
        else if x > 0 {
            return +1
        }
        else {
            return 0
        }
    }
    
}
