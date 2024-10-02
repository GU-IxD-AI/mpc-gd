//
//  CGRectExtension.swift
//  Engine
//
//  Created by Simon Colton on 09/10/2015.
//  Copyright © 2015 Simon Colton. All rights reserved.
//

import Foundation
import SpriteKit

extension CGRect {
    
    var centre: CGPoint { return CGPoint(x: midX, y: midY) }
    
    func scaledFromCentre(_ scale: CGFloat) -> CGRect{
        let xAdd = width * (scale - 1)
        let yAdd = height * (scale - 1)
        return CGRect(x: origin.x - xAdd/2, y: origin.y - yAdd/2, width: width * scale, height: height * scale)
    }
}
