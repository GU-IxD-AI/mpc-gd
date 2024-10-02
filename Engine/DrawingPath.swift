//
//  DrawingPath.swift
//  Engine
//
//  Created by Simon Colton on 29/03/2016.
//  Copyright © 2016 Simon Colton. All rights reserved.
//

import Foundation
import SpriteKit

class DrawingPath{
    
    var tag: DrawingPathTag = .Controller
    
    var tagNumber: Int = 0
    
    var visible = true
    
    var pathPoints: [CGPoint] = []
    
    var hue = CGFloat(0)
    
    var saturation = CGFloat(0)
    
    var brightness = CGFloat(0)
    
    var alpha = CGFloat(1)
    
    var strokeWidth = CGFloat(5)
    
    var filled = false
    
    var closed = false
    
    var isEraser = false
}
