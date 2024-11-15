//
//  DestroyBlueBlockingWhite.swift
//  MPCGD
//
//  Created by Simon Colton on 17/12/2016.
//  Copyright © 2016 ThoseMetamakers. All rights reserved.
//

import Foundation
import SpriteKit

class DestroyBlueBlockingWhites : MacroTactic {
    
    var blockingTime : [Int : CGFloat] = [:]
    
    override func findMacroActions(_ fascinator: Fascinator) -> [MacroAction] {
        var result : [MacroAction] = []
        
        let blues = fascinator.balls.filter({ b in b.type != settings.ballType })
        let whites = fascinator.balls.filter({b in b.type == settings.ballType })
        
        for blue in blues {
            var isCandidate = false
            
            let nearbyWhites = whites.filter({ white in (blue.node.position - white.node.position).magnitude() < (blue.radius + white.radius) * 1.1 })
            
            if nearbyWhites.count > 1 {
                var clusters : [[Ball]] = []
                for white in nearbyWhites {
                    if !clusters.contains(where: { c in c.containsIdentity(white) }) {
                        let cluster = fascinator.getCluster(white, clusterType: .same)
                        clusters.append(cluster)
                    }
                }
                
                let totalClusterSize : Int = clusters.reduce(0, { n, cluster in n + cluster.count })
                
                if clusters.count > 1
                    && (settings.destroyClusterBlockerOnly == false || totalClusterSize >= fascinator.chromosome.getBallSubChromosome(settings.ballType).criticalClusterSize.value) {
                    
                    isCandidate = true
                }
            }
            
            if isCandidate {
                var time = blockingTime[blue.id] ?? 0
                time += playtester.deltaTime
                blockingTime[blue.id] = time
                
                if time > settings.waitTime {
                    result.append(BallTapMacroAction(ball: blue))
                }
            }
            else {
                blockingTime[blue.id] = 0
            }
        }
        return result
    }
}

