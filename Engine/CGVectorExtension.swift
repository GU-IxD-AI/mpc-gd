//
//  CGVectorExtension.swift
//  Engine
//
//  Created by Simon Colton on 09/10/2015.
//  Copyright © 2018 ThoseMetamakers. All rights reserved.
//

import Foundation
import SpriteKit

extension CGVector {
    func sqrMagnitude() -> CGFloat {
        return dx*dx + dy*dy
    }
    
    func magnitude() -> CGFloat {
        return sqrt(sqrMagnitude())
    }
    
    func normalised() -> CGVector {
        if approxEquals(CGVector.zero) {
            return CGVector.zero
        }
        else {
            return self / magnitude()
        }
    }
    
    func clampMagnitude(min: CGFloat, max: CGFloat) -> CGVector {
        let sqrMag = sqrMagnitude()
        if sqrMag < min*min {
            return self.normalised() * min
        }
        else if sqrMag > max*max {
            return self.normalised() * max
        }
        else {
            return self
        }
    }
    
    func approxEquals(_ other: CGVector) -> Bool {
        let diff = self - other
        return diff.dx.approxEquals(0) && diff.dy.approxEquals(0)
    }
    
    func dot(_ other: CGVector) -> CGFloat {
        return self.dx * other.dx + self.dy * other.dy
    }
}


public func +(left: CGVector, right: CGVector) -> CGVector {
    return CGVector(dx: left.dx + right.dx, dy: left.dy + right.dy)
}

public func -(left: CGVector, right: CGVector) -> CGVector {
    return CGVector(dx: left.dx - right.dx, dy: left.dy - right.dy)
}

public func *(vector: CGVector, scalar: CGFloat) -> CGVector {
    return CGVector(dx: vector.dx * scalar, dy: vector.dy * scalar)
}

public func /(vector: CGVector, scalar: CGFloat) -> CGVector {
    return CGVector(dx: vector.dx / scalar, dy: vector.dy / scalar)
}

public func *(scalar: CGFloat, vector: CGVector) -> CGVector {
    return CGVector(dx: vector.dx * scalar, dy: vector.dy * scalar)
}

