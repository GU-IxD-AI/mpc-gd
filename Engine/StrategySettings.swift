//
//  StrategySettings.swift
//  MPCGD
//
//  Created by Simon Colton on 17/12/2016.
//  Copyright © 2016 ThoseMetamakers. All rights reserved.
//

import Foundation
import SpriteKit

class StrategySettings{
    
    enum TieBreakType : Int {
        case random
        case speed
        case distanceFromLeft, distanceFromRight, distanceFromTop, distanceFromBottom
        case clusterSize, touchingSameType, touchingOtherType
    }
    
    enum TieBreakChoice : Int { case smallest, largest }
    
    enum QuiescentCheckType : Int { case noMovement, friendsMaxed, foesMaxed, bothMaxed }
    
    var tactic: MacroTacticType = .none
    
    var ballType: Ball.BallType = .friend
    
    let waitTime = CGFloat(0)
    
    let quiescentCheck: QuiescentCheckType = .noMovement
    
    let destroyClusterBlockerOnly = true
    
    let distanceThreshold = CGFloat(1)
    
    let useMovementPrediction = true

    class TieBreakSettings : SubChromosome {
        let tieBreak = EnumGene<TieBreakType>(name: "$ tie break type", def: .random, designScreenName: .Strategy)
        let tieBreakChoice = EnumGene<TieBreakChoice>(name: "$ tie break choice", def: .smallest, designScreenName: .Strategy)
    }
    
    let tieBreakSettings: [TieBreakSettings] = []

}
