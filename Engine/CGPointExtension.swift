//
//  CGPointExtension.swift
//  Engine
//
//  Created by Simon Colton on 09/10/2015.
//  Copyright © 2015 Simon Colton. All rights reserved.
//

import Foundation
import SpriteKit

extension CGPoint {
    func approxEquals(_ other: CGPoint) -> Bool {
        let diff = self - other
        return diff.dx.approxEquals(0) && diff.dy.approxEquals(0)
    }
    
    func isInRadiusOf(_ other: CGPoint, radius: CGFloat) -> Bool{
        let diff = self - other
        return abs(diff.dx) < radius && abs(diff.dy) < radius
    }
    
}

public func +(left: CGPoint, right: CGVector) -> CGPoint {
    return CGPoint(x: left.x + right.dx, y: left.y + right.dy)
}

public func +(left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x + right.x, y: left.y + right.y)
}

public func -(left: CGPoint, right: CGVector) -> CGPoint {
    return CGPoint(x: left.x - right.dx, y: left.y - right.dy)
}

public func -(left: CGPoint, right: CGPoint) -> CGVector {
    return CGVector(dx: left.x - right.x, dy: left.y - right.y)
}

public func *(left: CGPoint, right: CGFloat) -> CGPoint {
    return CGPoint(x: left.x * right, y: left.y * right)
}
