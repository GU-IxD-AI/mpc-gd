//
//  JackFrostPlaytester
//  MPCGD
//
//  Created by Simon Colton on 06/01/2017.
//  Copyright © 2017 ThoseMetamakers. All rights reserved.
//

import Foundation
import SpriteKit

class JackFrostPlaytester: MacroTacticPlaytester{
    
    init(fascinator: Fascinator){
        let playerSettings = AutoplayerSettings()
        let strategy = StrategySettings()
        strategy.tactic = .jackFrostTactic
        strategy.ballType = .foe
        
        let strategySettings = [strategy]
        super.init(fascinator: fascinator, playerSettings: playerSettings, strategySettings: strategySettings)
    }

}
