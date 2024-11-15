//
//  WhenQuiescent.swift
//  MPCGD
//
//  Created by Simon Colton on 17/12/2016.
//  Copyright © 2016 ThoseMetamakers. All rights reserved.
//

import Foundation
import SpriteKit

class WhenQuiescent : MacroTactic {
    
    var quiescentTime = CGFloat(0)
    
    func isBallTypeMaxed(_ type: Ball.BallType, fascinator: Fascinator) -> Bool {
        let max = fascinator.chromosome.getBallSubChromosome(type).maxBalls.value
        return fascinator.balls.filter({ b in b.type == type }).count >= max
    }
    
    func isQuiescent(_ fascinator: Fascinator) -> Bool {
        switch settings.quiescentCheck {
        case .noMovement:
            let thresholdSquared = pow(settings.distanceThreshold, 2)
            for ball in fascinator.balls {
                if ball.node.physicsBody!.velocity.sqrMagnitude() > thresholdSquared {
                    return false
                }
            }
            
            return true
            
        case .friendsMaxed:
            return isBallTypeMaxed(.friend, fascinator: fascinator)
            
        case .foesMaxed:
            return isBallTypeMaxed(.foe, fascinator: fascinator)
            
        case .bothMaxed:
            return isBallTypeMaxed(.friend, fascinator: fascinator) && isBallTypeMaxed(.foe, fascinator: fascinator)
        }
    }
    
    func getActionsWhenQuiescent(_ fascinator: Fascinator) -> [MacroAction] {
        fatalError("This function must be overridden")
    }
    
    override func findMacroActions(_ fascinator: Fascinator) -> [MacroAction] {
        if isQuiescent(fascinator) {
            quiescentTime += playtester.deltaTime
            
            if quiescentTime >= settings.waitTime {
                quiescentTime = 0
                return getActionsWhenQuiescent(fascinator)
            }
            else {
                return []
            }
        }
        else {
            quiescentTime = 0
            return []
        }
    }
}
