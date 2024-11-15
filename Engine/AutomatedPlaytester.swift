//
//  AutomatedPlaytester.swift
//  Engine
//
//  Created by Powley, Edward on 09/03/2016.
//  Copyright © 2016 ThoseMetamakers. All rights reserved.
//

import Foundation
import SpriteKit

class AutomatedPlaytester {
    
    unowned let fascinator : Fascinator
    
    let showHand = true
    let handSize : CGFloat = 200 // 100
    let handAlpha : CGFloat = 1 // 0.25
    let handNode : SKSpriteNode!
    
    let deltaTime: CGFloat
    let tickInterval : Int
    var gameTicksSinceLastPlayerTick : Int
    
    fileprivate(set) var lastTouchPoint : CGPoint? = nil
    
    init(fascinator: Fascinator, playerSettings: AutoplayerSettings) {
        self.fascinator = fascinator
        
        tickInterval = playerSettings.updateInterval
        deltaTime = CGFloat(tickInterval) / 60.0
        gameTicksSinceLastPlayerTick = tickInterval
        
        if showHand {
            handNode = SKSpriteNode(imageNamed: "AIHand")
            //handNode.size = CGSize(width: handSize, height: handSize)
            handNode.anchorPoint = CGPoint(x: 0.05, y: 0.95)
            handNode.alpha = 0
            handNode.zPosition = ZPositionConstants.automatedPlaytesterHand
            fascinator.fascinatorSKNode.addChild(handNode)
        }
        else {
            handNode = nil
        }
    }
    
    deinit {
        if handNode != nil {
            handNode.removeFromParent()
        }
    }
    
    final func tick() {
        gameTicksSinceLastPlayerTick += 1
        if gameTicksSinceLastPlayerTick >= tickInterval {
            gameTicksSinceLastPlayerTick = 0
            
            if let touchPoint = doAI() {
                if !touchPoint.x.isNaN { // Hack: if doAI returns (NaN, NaN), do nothing
                    if lastTouchPoint == nil {
                        fascinator.touchesBegan(touchPoint)
                    }
                    else {
                        let delta = touchPoint - lastTouchPoint!
                        fascinator.touchesDragged(touchPoint, clampedDragVector: delta, dragVector: delta)
                    }
                    
                    lastTouchPoint = touchPoint
                    
                    if handNode != nil {
                        handNode.removeAllActions()
                        handNode.alpha = handAlpha
                        handNode.position = touchPoint
                        handNode.zRotation = -(touchPoint.x/fascinator.sceneSize.width) * (CGFloat.pi / 10)
                    }
                }
            }
            else {
                if lastTouchPoint != nil {
                    fascinator.touchesEnded(lastTouchPoint!)
                }
                
                lastTouchPoint = nil
                
                if handNode != nil {
                    handNode.performAction(SKAction.fadeOut(withDuration: 0.5))
                }
            }
        }

    }
    
    func doAI() -> CGPoint? {
        return nil
    }
}
