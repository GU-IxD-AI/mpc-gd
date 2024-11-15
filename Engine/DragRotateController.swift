//
//  DragRotateController.swift
//  Engine
//
//  Created by Powley, Edward on 21/01/2016.
//  Copyright © 2016 ThoseMetamakers. All rights reserved.
//

import Foundation
import SpriteKit

class DragRotateController : ArtImageController {
    
    unowned let fascinator : Fascinator
    var dragAngle = CGFloat(0)
    var targetAngle : CGFloat! = nil
    
    required init(fascinator: Fascinator) {
        self.fascinator = fascinator
    }
    
    func touchBegan(_ touchPoint: CGPoint) {
        let touchOffset = touchPoint - fascinator.attachmentPoint
        dragAngle = atan2(touchOffset.dy, touchOffset.dx) - fascinator.artImageNode.zRotation
        targetAngle = fascinator.artImageNode.zRotation
    }
    
    func touchDragged(_ touchPoint: CGPoint) {
        let touchOffset = touchPoint - fascinator.attachmentPoint
        targetAngle = atan2(touchOffset.dy, touchOffset.dx) - dragAngle
    }
    
    func touchEnded(_ touchPoint: CGPoint) {
        targetAngle = nil
    }
    
    func tick(_ currentTime: CFTimeInterval) {
        if targetAngle != nil {
            var angle = targetAngle - fascinator.artImageNode.zRotation
            while (angle > CGFloat.pi) { angle = angle - CGFloat.pi*2; }
            while (angle < -CGFloat.pi) { angle = angle + CGFloat.pi*2; }
            if fascinator.artImageNode != nil && fascinator.artImageNode.physicsBody != nil{
                
                // HACK FOR LET IT SNOW - USED TO BE angle * 10
                fascinator.artImageNode.physicsBody!.angularVelocity = angle * 20
            }
        }
    }
}

