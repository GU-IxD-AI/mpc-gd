//
//  RandomUtils.swift
//  Fask
//
//  Created by Simon Colton on 12/09/2015.
//  Copyright (c) 2018 ThoseMetamakers. All rights reserved.
//

import Foundation
import SpriteKit

class RandomUtils{
    
    static func randomBool() -> Bool{
        let r = arc4random_uniform(UInt32(2))
        return r==1
    }
    
    static func randomBool(probTrue: CGFloat) -> Bool {
        return randomFloat(0, upperInc: 1) < probTrue
    }
    
    static func randomInt(_ lowerInc: Int, upperInc: Int) -> Int{
        let dist = (upperInc - lowerInc + 1)
        let r = arc4random_uniform(UInt32(dist))
        return lowerInc + Int(r)
    }
    
    static func randomFloat(_ lowerInc: CGFloat, upperInc: CGFloat) -> CGFloat {
        let r = arc4random_uniform(UINT32_MAX)
        return lowerInc + CGFloat(r) / CGFloat(UINT32_MAX) * (upperInc - lowerInc)
    }
    
    static func randomChoice<T>(_ array: [T]) -> T! {
        if array.isEmpty {
            return nil
        }
        else if array.count == 1 {
            return array.first!
        }
        else {
            let index = randomInt(0, upperInc: array.count - 1)
            return array[index]
        }
    }
    
    static func randomiseArrayOrder(_ array: inout [Int]){
        let size = array.count - 1
        for _ in 0...array.count * 2{
            let pos1 = RandomUtils.randomInt(0, upperInc: size)
            let pos2 = RandomUtils.randomInt(0, upperInc: size)
            let oldVal = array[pos1]
            array[pos1] = array[pos2]
            array[pos2] = oldVal
        }
    }
    
    static func randomUniformInCircle(_ radius: CGFloat) -> CGVector {
        // Uniform distribution inside circle
        // See http://www.anderswallin.net/2009/05/uniform-random-points-in-a-circle-using-polar-coordinates/
        
        let r = radius * sqrt(randomFloat(0, upperInc: 1))
        let theta = randomFloat(0, upperInc: 2 * MathsUtils.π)
        return CGVector(dx: r * cos(theta), dy: r * sin(theta))
    }
}
