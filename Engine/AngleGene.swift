//
//  AngleGene.swift
//  Engine
//
//  Created by Powley, Edward on 02/03/2016.
//  Copyright © 2016 Simon Colton. All rights reserved.
//

import Foundation
import SpriteKit

class AngleGene : FloatGene {
    
    init(name: String, step: CGFloat, def: CGFloat, designScreenName: DesignScreenName) {
        super.init(name: name, min: 0, max: 360 - step/2, step: step, def: def, designScreenName: designScreenName)
    }
    
    override func displayValueAsIcon(value: CGFloat, size: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, 1)
        let context = UIGraphicsGetCurrentContext()!
        CGContextSetLineWidth(context, 3)
        
        let angleRadians = MathsUtils.degreesToRadians(value)
        let radius = min(size.width, size.height) * 1.0/3.0
        let centre = size.centrePoint()
        let otherPoint = centre + radius * CGVector(dx: cos(angleRadians), dy: sin(angleRadians))
        
        DrawingShapes.strokeLineOnContext(context, colour: Colours.darkGray, point1: centre, point2: otherPoint)
        
        let buttonIcon = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return buttonIcon
    }
    
    var degrees : CGFloat { return value }
    var radians : CGFloat { return MathsUtils.degreesToRadians(value) }
    var unitVector : CGVector { return CGVector(dx: cos(radians), dy: sin(radians)) }
}
