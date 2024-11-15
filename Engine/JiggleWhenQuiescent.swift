//
//  JiggleWhenQuiescent.swift
//  MPCGD
//
//  Created by Simon Colton on 17/12/2016.
//  Copyright © 2016 ThoseMetamakers. All rights reserved.
//

import Foundation
import SpriteKit

class JiggleWhenQuiescent : TapRandomlyWhenQuiescent {
    
    func findPointNotOnBall(_ fascinator: Fascinator) -> CGPoint! {
        for _ in 1 ... 100 {
            let x = RandomUtils.randomFloat(0, upperInc: fascinator.sceneSize.width)
            let y = RandomUtils.randomFloat(0, upperInc: fascinator.sceneSize.height)
            let point = CGPoint(x: x, y: y)
            var isOK = true
            for ball in fascinator.balls {
                if point.isInRadiusOf(ball.node.position, radius: ball.radius) {
                    isOK = false
                    break
                }
            }
            if isOK {
                return point
            }
        }
        
        return nil
    }
    
    override func getActionsWhenQuiescent(_ fascinator: Fascinator) -> [MacroAction] {
        if let start = findPointNotOnBall(fascinator) {
            let end = start + RandomUtils.randomUniformInCircle(30)
            return [LinearDragMacroAction(start: start, end: end, dragDuration: 2)]
        }
        else {
            return []
        }
    }
}
