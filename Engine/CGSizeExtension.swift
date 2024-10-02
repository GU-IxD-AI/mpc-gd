//
//  CGSizeExtension.swift
//  Engine
//
//  Created by Simon Colton on 09/10/2015.
//  Copyright © 2015 Simon Colton. All rights reserved.
//

import Foundation
import SpriteKit

extension CGSize {
    func toVector() -> CGVector {
        return CGVector(dx: width, dy: height)
    }
    
    func doubled() -> CGSize {
        return CGSize(width: width * 2, height: height * 2)
    }
    
    func halved() -> CGSize {
        return CGSize(width: width / 2, height: height / 2)
    }
    
    func centrePoint() -> CGPoint{
        return CGPoint(x: width/2, y: height/2)
    }
}

public func *(size: CGSize, scalar: CGFloat) -> CGSize {
    return CGSize(width: size.width * scalar, height: size.height * scalar)
}

public func *(scalar: CGFloat, size: CGSize) -> CGSize {
    return CGSize(width: size.width * scalar, height: size.height * scalar)
}
