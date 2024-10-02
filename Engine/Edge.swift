//
//  Edge.swift
//  Engine
//
//  Created by Powley, Edward on 23/11/2015.
//  Copyright © 2015 Simon Colton. All rights reserved.
//

import Foundation
import SpriteKit

enum Edge : Int {
    case bottom, right, top, left
    
    var opposite: Edge { return Edge(rawValue: (self.rawValue + 2) % 4)! }
    
    static let allEdges: [Edge] = [.bottom, .right, .top, .left]
    
    var directionVector : CGVector {
        switch self {
        case .left:
            return CGVector(dx: -1, dy: 0)
        case .right:
            return CGVector(dx: +1, dy: 0)
        case .bottom:
            return CGVector(dx: 0, dy: -1)
        case .top:
            return CGVector(dx: 0, dy: +1)
        }
    }
    
    var mask : UInt32 {
        return UInt32(1) << UInt32(self.rawValue)
    }
}
