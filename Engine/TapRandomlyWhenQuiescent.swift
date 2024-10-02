//
//  TapRandomlyWhenQuiescent.swift
//  MPCGD
//
//  Created by Simon Colton on 17/12/2016.
//  Copyright © 2016 Simon Colton. All rights reserved.
//

import Foundation
import SpriteKit

class TapRandomlyWhenQuiescent : WhenQuiescent {
    override func getActionsWhenQuiescent(_ fascinator: Fascinator) -> [MacroAction] {
        
        // Allow a tap on any ball of the correct type
        
        return fascinator.balls
            .filter({ b in b.type == settings.ballType })
            .map({ b in BallTapMacroAction(ball: b) })
        
    }
}
