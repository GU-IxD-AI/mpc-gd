
//
//  Patterns.swift
//  Engine
//
//  Created by Simon Colton on 22/05/2016.
//  Copyright © 2016 ThoseMetamakers. All rights reserved.
//

import Foundation
import SpriteKit

class Patterns{
    
    // Patterns from subtlepatterns.com
    
    static func getRandomPatternImage(_ size: CGSize) -> UIImage{
        UIGraphicsBeginImageContextWithOptions(size, true, 1)
        let context = UIGraphicsGetCurrentContext()
        let lines = FileUtils.readFileLines("PatternList", fileType: "txt")!
        let numLines = lines.count
        let r = RandomUtils.randomInt(0, upperInc: numLines - 1)
        let patternName = lines[r]
        let pattern = UIImage(named: patternName)!
        var x = CGFloat(0)
        while x < size.width{
            var y = CGFloat(0)
            while y < size.height{
                ImageUtils.drawImageOntoContextAtPosition(context!, baseImageHeight: size.height, image: pattern, position: CGPoint(x: x, y: y))
                y += pattern.size.height
            }
            x += pattern.size.width
        }
        let patternImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return patternImage!
    }
    
}
