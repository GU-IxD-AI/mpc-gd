//
//  PhysicsUtils.swift
//  Beeee
//
//  Created by Powley, Edward on 07/09/2015.
//  Copyright (c) 2018 ThoseMetamakers. All rights reserved.
//

import Foundation
import SpriteKit
import SpriteKit

class PhysicsUtils {
    
    static func createBodyFromImage(_ image: UIImage, detailLevel: Int, size: CGSize) -> SKPhysicsBody {
        let islands = getImageIslandsForBody(image, detailLevel: detailLevel)
        return createBodyFromImageIslands(islands, size: size)
    }
    
    static func getImageIslandsForBody(_ image: UIImage, detailLevel: Int) -> [SKTexture] {
        
        assert(detailLevel >= 1, "Invalid detail level")
        let scaledImage = ImageUtils.getScaledImage(image, scale: CGFloat(1.0) / CGFloat(detailLevel))
        let islands = ImageUtils.getImageIslandsOnWhite(scaledImage, ignoreIslandsAtEdges: false)
        let islandTextures = islands.map({image in SKTexture(image: image)})
        return islandTextures
    }
    
    static func getCentreOfMassFromImageIslands(_ islands: [SKTexture], size: CGSize) -> CGPoint {
        var averagePoint = CGPoint.zero
        var numPoints = 0
        
        for island in islands {
            let data = ImageData(cgImage: island.cgImage())
            for x in 0 ..< Int(data.bounds.width) {
                for y in 0 ..< Int(data.bounds.height) {
                    if data.rgbaTupleAt(x, y: y).3 > 0 {
                        let px = (CGFloat(x) - data.bounds.centre.x) / data.bounds.width * size.width
                        let py = -(CGFloat(y) - data.bounds.centre.y) / data.bounds.height * size.height
                        averagePoint = averagePoint + CGPoint(x: px, y: py)
                        numPoints += 1
                    }
                }
            }
        }
        
        if numPoints == 0 {
            return CGPoint.zero
        }
        
        return averagePoint * (1.0 / CGFloat(numPoints))
    }
    
    static func createBodyFromImageIslands(_ islands: [SKTexture], size: CGSize) -> SKPhysicsBody {
        
        var bodies: [SKPhysicsBody] = []
        for texture in islands {
            let body: SKPhysicsBody? = SKPhysicsBody(texture: texture, size: size)
            
            if body != nil {
                bodies.append(body!)
            }
        }
        
        if bodies.count == 0 {
  //          assertionFailure("No bodies")
            return SKPhysicsBody(circleOfRadius: 1)
        }
        else if islands.count == 1 {
            return bodies.first!
        }
        else {
            return SKPhysicsBody(bodies: bodies)
        }
    }
    
}
