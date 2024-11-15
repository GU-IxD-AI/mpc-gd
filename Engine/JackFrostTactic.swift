//
//  JackFrostTactic
//  MPCGD
//
//  Created by Simon Colton on 06/01/2017.
//  Copyright © 2017 ThoseMetamakers. All rights reserved.
//

import Foundation
import SpriteKit

class JackFrostTactic: MacroTactic{
    
    override func findMacroActions(_ fascinator: Fascinator) -> [MacroAction] {
        var result : [MacroAction] = []
        
        let blues = fascinator.balls.filter({ b in b.type != settings.ballType })
        let whites = fascinator.balls.filter({b in b.type == settings.ballType })
        
        var clusterSizes: [Int] = []
        for (clusterType, count) in fascinator.countClusters() {
            if clusterType == settings.ballType{
                clusterSizes.append(count)
            }
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
                for white in whites{
                    let dist = nearestDistance(blue, white)
                    if dist < (blue.radius + white.radius) * settings.distanceThreshold {
                        let cluster = fascinator.getCluster(white, clusterType: .same)
                        if cluster.count >= minClusterSize{
                            result.append(BallTapMacroAction(ball: blue))
                        }
                    }
                }
            }
        }
        return result
    }
    
}
