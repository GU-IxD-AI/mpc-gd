//
//  SlushSloshTacticswift.swift
//  MPCGD
//
//  Created by Simon Colton on 06/01/2017.
//  Copyright © 2017 ThoseMetamakers. All rights reserved.
//

import Foundation
import SpriteKit

class SlushSloshTactic: MacroTactic{
    
    
    override func findMacroActions(_ fascinator: Fascinator) -> [MacroAction] {
        var result : [MacroAction] = []
        
        let blues = fascinator.balls.filter({ b in b.type == settings.ballType })
        
        var clusterSizes: [Int] = []
        for (_, count) in fascinator.countClusters() {
            clusterSizes.append(count)
        }
        clusterSizes.sort()
        var minClusterSize = 1
        var pos = clusterSizes.count - 1
        while pos >= 0 && pos >= clusterSizes.count - 3{
            minClusterSize = clusterSizes[pos]
            pos = pos - 1
        }

        for blue in blues {
            if blue.node.position.y < fascinator.sceneSize.height - 30{
                for blue2 in blues{
                    if blue.id != blue2.id{
                        let dist = nearestDistance(blue, blue2)
                        if dist < (blue.radius + blue2.radius) * settings.distanceThreshold {
                            let cluster = fascinator.getCluster(blue2, clusterType: .dontCare)
                            if cluster.count >= minClusterSize{
                                result.append(BallTapMacroAction(ball: blue))
                            }
                        }
                    }
                }
            }
        }
        return result
    }

    
}
