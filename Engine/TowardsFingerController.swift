//
//  TowardsFingerController.swift
//  Engine
//
//  Created by Powley, Edward on 21/01/2016.
//  Copyright © 2016 ThoseMetamakers. All rights reserved.
//

import Foundation
import SpriteKit

class TowardsFingerController : ArtImageController {
    
    unowned let fascinator : Fascinator
    var targetPoint: CGPoint! = nil
    var aimPoint: CGPoint! = nil
    
    let minDistance: CGFloat = 5
    let forceAmount: CGFloat = 10000
    
    required init(fascinator: Fascinator) {
        self.fascinator = fascinator
    }
    
    func touchBegan(_ touchPoint: CGPoint) {
        targetPoint = touchPoint
        aimPoint = touchPoint
    }
    
    func touchDragged(_ touchPoint: CGPoint) {
        targetPoint = touchPoint
        aimPoint = touchPoint
    }
    
    func touchEnded(_ touchPoint: CGPoint) {
        targetPoint = nil
        // Don't set aimPoint to nil here
    }
    
    func tick(_ currentTime: CFTimeInterval) {
        if targetPoint != nil {
            let offset = targetPoint - fascinator.artImageNode.position
            let distance = offset.magnitude()
            let direction = offset / distance
            
            if distance > minDistance {
                let force = direction * forceAmount
                if fascinator.artImageNode != nil && fascinator.artImageNode.physicsBody != nil{
                    fascinator.artImageNode.physicsBody!.applyForce(force)
                }
            }
        }
        
        if aimPoint != nil {
            let offset = aimPoint - fascinator.artImageNode.position
            
            let targetAngle = atan2(-offset.dx, offset.dy) - MathsUtils.degreesToRadians(fascinator.chromosome.forwardDirection.value)
            var angle = targetAngle - fascinator.artImageNode.zRotation
            while (angle > CGFloat.pi) { angle = angle - 2 * CGFloat.pi; }
            while (angle < -CGFloat.pi) { angle = angle + 2 * CGFloat.pi; }
            
            if fascinator.artImageNode != nil && fascinator.artImageNode.physicsBody != nil{
                fascinator.artImageNode.physicsBody!.angularVelocity = angle * 10
            }
        }
    }
}
