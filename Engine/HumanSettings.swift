//
//  HumanSettings.swift
//  Engine
//
//  Created by Simon Colton on 10/03/2016.
//  Copyright © 2016 ThoseMetamakers. All rights reserved.
//

import Foundation
import SpriteKit

class HumanSettings{
    
    /*
    let minTimeBetweenActions = FloatGene(name: "time between actions", min: 0, max: 2, step: 0.01, def: 0.25, designScreenName: .Human)
    let reactionTime = FloatGene(name: "max reaction delay", min: 0, max: 2, step: 0.01, def: 0.1, designScreenName: .Human)
    let tapError = FloatGene(name: "max tap position error", min: 0, max: 100, step: 0.1, def: 0, designScreenName: .Human)
    let tieBreakFuzz = FloatGene(name: "tie break fuzziness", min: 0, max: 100, step: 0.1, def: 0, designScreenName: .Human)
 */
    
    let minTimeBetweenActions = CGFloat(0)
    
    let reactionTime = CGFloat(0)
    
    let tapError = CGFloat(0)
    
    let tieBreakFuzz = CGFloat(0)
    
    init() {

    }
    
}
