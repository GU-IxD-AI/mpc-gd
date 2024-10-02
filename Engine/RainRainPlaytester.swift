//
//  RainRainPlaytester.swift
//  MPCGD
//
//  Created by Simon Colton on 26/12/2016.
//  Copyright © 2016 Simon Colton. All rights reserved.
//

import Foundation
import SpriteKit

class RainRainPlaytester : MacroTacticPlaytester{
    
    init(fascinator: Fascinator){
        let playerSettings = AutoplayerSettings()
        let stopClusterStrategy = StrategySettings()
        stopClusterStrategy.tactic = .rainRainTactic
        stopClusterStrategy.ballType = .friend
        let strategySettings = [stopClusterStrategy]
        super.init(fascinator: fascinator, playerSettings: playerSettings, strategySettings: strategySettings)
    }
    
}
