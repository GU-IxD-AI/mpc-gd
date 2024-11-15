//
//  GridSwipeController.swift
//  Engine
//
//  Created by Powley, Edward on 09/02/2016.
//  Copyright © 2016 ThoseMetamakers. All rights reserved.
//

import Foundation
import SpriteKit

class GridSwipeController : ArtImageController{
    
    unowned let fascinator : Fascinator
    
    var swipeBeginPoint : CGPoint? = nil
    let swipeThreshold : CGFloat = 10
    
    required init(fascinator: Fascinator) {
        self.fascinator = fascinator
    }
    
    func touchBegan(_ touchPoint: CGPoint) {
        swipeBeginPoint = touchPoint
    }
    
    func touchDragged(_ touchPoint: CGPoint) {
        
    }
    
    func touchEnded(_ touchPoint: CGPoint) {
        if swipeBeginPoint != nil {
            var delta = touchPoint - swipeBeginPoint!
            if delta.magnitude() < swipeThreshold {
                let angle = MathsUtils.degreesToRadians(fascinator.chromosome.forwardDirection.value)
                delta = CGVector(dx: cos(angle), dy: sin(angle))
            }
            let bounds = fascinator.artImageBoundingBox.offsetBy(dx: fascinator.artImageNode.position.x, dy: fascinator.artImageNode.position.y)

            if abs(delta.dx) > abs(delta.dy) {
                var targetPoint = fascinator.imageTargetGridPoint + CGVector(dx: MathsUtils.sign(delta.dx) * fascinator.gridSquareSize.width, dy: 0)
                if targetPoint.x + bounds.width/2 > fascinator.sceneSize.width{
                    targetPoint.x = fascinator.sceneSize.width - bounds.width/2
                }
                if targetPoint.x - bounds.width/2 < 0{
                    targetPoint.x = bounds.width/2
                }
                fascinator.imageGridPointOverride = fascinator.getNearestGridPoint(targetPoint)
            }
            else {
                var targetPoint = fascinator.imageTargetGridPoint + CGVector(dx: 0, dy: MathsUtils.sign(delta.dy) * fascinator.gridSquareSize.height)
                if targetPoint.y + bounds.height/2 > fascinator.sceneSize.height{
                    targetPoint.y = fascinator.sceneSize.height - bounds.height/2
                }
                if targetPoint.y - bounds.height/2 < 0{
                    targetPoint.y = bounds.height/2
                }
                fascinator.imageGridPointOverride = fascinator.getNearestGridPoint(targetPoint)
            }
        }
        swipeBeginPoint = nil
    }
    
    func tick(_ currentTime: CFTimeInterval) {
        
    }
    
}
