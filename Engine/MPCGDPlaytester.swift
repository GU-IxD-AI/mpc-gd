//
//  MPCGDPlaytester.swift
//  MPCGD
//
//  Created by Simon Colton on 17/12/2016.
//  Copyright © 2016 Simon Colton. All rights reserved.
//

import Foundation
import SpriteKit

class MPCGDPlaytester: MacroTacticPlaytester{
    
    init(fascinator: Fascinator){
        let playerSettings = AutoplayerSettings()
        
        let stopClusterStrategy = StrategySettings()
        stopClusterStrategy.tactic = .stopClusterFromForming
        stopClusterStrategy.ballType = .friend
        
        let jiggleWhenQuiescentStrategy = StrategySettings()
        jiggleWhenQuiescentStrategy.tactic = .jiggleWhenQuiescent
        
        let destroyBlueBlockingWhiteStrategy = StrategySettings()
        destroyBlueBlockingWhiteStrategy.tactic = .destroyBlueBlockingWhites
        destroyBlueBlockingWhiteStrategy.ballType = .friend
        
        let tapRandomlyWhenQuiescentStrategy = StrategySettings()
        tapRandomlyWhenQuiescentStrategy.tactic = .tapRandomlyWhenQuiescent
        tapRandomlyWhenQuiescentStrategy.ballType = .friend
        
        let strategySettings = [stopClusterStrategy, destroyBlueBlockingWhiteStrategy, tapRandomlyWhenQuiescentStrategy]
        super.init(fascinator: fascinator, playerSettings: playerSettings, strategySettings: strategySettings)
    }
    
}
