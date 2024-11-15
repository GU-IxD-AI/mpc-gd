//
//  StopClusterFromForming.swift
//  MPCGD
//
//  Created by Simon Colton on 17/12/2016.
//  Copyright © 2016 ThoseMetamakers. All rights reserved.
//

import Foundation
import SpriteKit

class StopClusterFromForming : MacroTactic {
    
    override func findMacroActions(_ fascinator: Fascinator) -> [MacroAction] {
        var result : [MacroAction] = []
        let blues = fascinator.balls.filter({ b in b.type == settings.ballType })
        for i in 0 ..< blues.count {
            let ballA = blues[i]
            for j in 0 ..< i {
                let ballB = blues[j]
                let dist = nearestDistance(ballA, ballB)
                if dist < (ballA.radius + ballB.radius) * settings.distanceThreshold {
                    let clusterA = fascinator.getCluster(ballA, clusterType: .same)
                    if !clusterA.containsIdentity(ballB) {
                        let clusterB = fascinator.getCluster(ballB, clusterType: .same)
                        if clusterA.count + clusterB.count >= fascinator.chromosome.getBallSubChromosome(settings.ballType).criticalClusterSize.value {
                            /*let line = CGPathCreateMutable()
                             CGPathMoveToPoint(line, nil, ballA.node.position.x, ballA.node.position.y)
                             CGPathAddLineToPoint(line, nil, ballB.node.position.x, ballB.node.position.y)
                             let node = SKShapeNode(path: line)
                             node.alpha = 0.5
                             node.strokeColor = UIColor.greenColor()
                             node.lineWidth = 4
                             node.zPosition = ZPositionConstants.automatedPlaytesterHand
                             fascinator.fascinatorSKNode.addChild(node)
                             node.performAction(SKAction.sequence([
                             SKAction.fadeOutWithDuration(0.5),
                             SKAction.removeFromParent()
                             ]))*/
                            
                            result.append(BallTapMacroAction(ball: ballA))
                            result.append(BallTapMacroAction(ball: ballB))
                        }
                    }
                }
            }
        }
        return result
    }
}
