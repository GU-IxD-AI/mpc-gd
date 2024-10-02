//
//  MakeItStopPlaytester.swift
//  MPCGD
//
//  Created by Simon Colton on 21/12/2016.
//  Copyright © 2016 Simon Colton. All rights reserved.
//

import Foundation
import SpriteKit

class MakeItStopPlaytester: MacroTacticPlaytester{
    
    init(fascinator: Fascinator){
        let playerSettings = AutoplayerSettings()
  
        let stopBlueClusterStrategy = StrategySettings()
        stopBlueClusterStrategy.tactic = .stopClusterFromForming
        stopBlueClusterStrategy.ballType = .friend

        let stopWhiteClusterStrategy = StrategySettings()
        stopWhiteClusterStrategy.tactic = .stopClusterFromForming
        stopWhiteClusterStrategy.ballType = .foe

        let strategySettings: [StrategySettings] = [stopWhiteClusterStrategy, stopBlueClusterStrategy]
        
        super.init(fascinator: fascinator, playerSettings: playerSettings, strategySettings: strategySettings)
    }
}
