//
//  AssistantPlayTester.swift
//  MPCGD
//
//  Created by Simon Colton on 21/12/2016.
//  Copyright © 2016 Simon Colton. All rights reserved.
//

import Foundation
import SpriteKit

class AssistantPlaytester: MacroTacticPlaytester{
    
    init(fascinator: Fascinator){
        let playerSettings = AutoplayerSettings()
        let stopClusterStrategy = StrategySettings()
        stopClusterStrategy.tactic = .stopClusterFromForming
        stopClusterStrategy.ballType = .friend
        
        let strategySettings = [stopClusterStrategy]
        super.init(fascinator: fascinator, playerSettings: playerSettings, strategySettings: strategySettings)
    }
    
}
