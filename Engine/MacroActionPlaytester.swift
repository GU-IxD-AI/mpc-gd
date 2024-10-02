//
//  MacroActionPlaytester.swift
//  Engine
//
//  Created by Powley, Edward on 09/03/2016.
//  Copyright © 2016 Simon Colton. All rights reserved.
//

import Foundation
import SpriteKit

class MacroActionPlaytester : AutomatedPlaytester {
    var currentMacroAction : MacroAction
    
    override init(fascinator: Fascinator, playerSettings: AutoplayerSettings) {
        currentMacroAction = DoNothingMacroAction(duration: 0)
        super.init(fascinator: fascinator, playerSettings: playerSettings)
    }
    
    override func doAI() -> CGPoint? {
        if currentMacroAction.hasFinished() {
            currentMacroAction = selectNextMacroAction()
        }
        
        if let ballTap = currentMacroAction as? BallTapMacroAction {
            // Hack: for ball taps, bypass the tap emulation so as not to interrupt user drags
            let touchPoint = ballTap.ball.node.position
            fascinator.ballTouched(ballTap.ball)
            if handNode != nil {
                handNode.removeAllActions()
                handNode.alpha = handAlpha
                handNode.position = touchPoint
                handNode.zRotation = -(touchPoint.x/fascinator.sceneSize.width) * (CGFloat.pi/10)
            }
            
            currentMacroAction = selectNextMacroAction()

            return CGPoint(x: CGFloat.nan, y: CGFloat.nan)
        }
        else {
            return currentMacroAction.getNextAction()
        }
    }
    
    func selectNextMacroAction() -> MacroAction {
        return DoNothingMacroAction(duration: 1)
    }
}
