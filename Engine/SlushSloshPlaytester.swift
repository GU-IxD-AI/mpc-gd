//
//  SlushFlowPlaytester.swift
//  MPCGD
//
//  Created by Simon Colton on 06/01/2017.
//  Copyright © 2017 Simon Colton. All rights reserved.
//

import Foundation
import SpriteKit

class SlushSloshPlaytester: MacroTacticPlaytester{
    
    init(fascinator: Fascinator){
        let playerSettings = AutoplayerSettings()
        let strategy = StrategySettings()
        strategy.tactic = .slushSloshTactic
        strategy.ballType = .friend
        let strategySettings = [strategy]
        super.init(fascinator: fascinator, playerSettings: playerSettings, strategySettings: strategySettings)
    }
    
}
