//
//  LogarithmicFloatGene.swift
//  Engine
//
//  Created by Simon Colton on 09/10/2015.
//  Copyright © 2018 ThoseMetamakers. All rights reserved.
//

import Foundation
import SpriteKit

/// A gene of floating point type, using a logarithmic scale
class LogarithmicFloatGene : Gene<CGFloat> {
    let logMin, logMax, logStep : CGFloat
    
    init(name: String, min: CGFloat, max: CGFloat, numSteps: Int, alsoAllowZero: Bool, def: CGFloat, designScreenName: DesignScreenName) {
        assert(min > 0 && max > 0 && min < max, "LogarithmicFloatGene range must be positive")
        
        self.logMin = log(min)
        self.logMax = log(max)
        self.logStep = (logMax - logMin) / CGFloat(numSteps)
        
        let intDef = (def == 0) ? -1 : Int(round((log(def) - logMin) / logStep))
        
        super.init(name: name, min: alsoAllowZero ? -1 : 0, max: numSteps, def: intDef, designScreenName: designScreenName)
    }
    
    override func mapToValue(_ geneValue: Int) -> CGFloat! {
        if geneValue == -1 {
            return 0
        }
        else {
            let logValue = logMin + CGFloat(geneValue) * logStep
            return exp(logValue)
        }
    }
    
    override func mapValueToInt(_ value: CGFloat) -> Int! {
        if value == 0 {
            return -1
        }
        else {
            let logValue = log(value)
            let geneValue = (logValue - logMin) / logStep
            return Int(round(geneValue))
        }
    }    
}
