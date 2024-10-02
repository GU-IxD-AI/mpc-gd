//
//  FloatGene.swift
//  Engine
//
//  Created by Simon Colton on 09/10/2015.
//  Copyright © 2015 Simon Colton. All rights reserved.
//

import Foundation
import SpriteKit

/// A gene of floating point type
class FloatGene : Gene<CGFloat> {
    let step : CGFloat
    let decimals : Int
    
    init(name: String, min: CGFloat, max: CGFloat, step: CGFloat, def: CGFloat, designScreenName: DesignScreenName) {
        self.step = step
        decimals = MathsUtils.requiredDecimals(step)
        
        let intMin = Int(ceil(min / step))
        let intMax = Int(floor(max / step))
        let intDef = Int(round(def / step))
        
        super.init(name: name, min: intMin, max: intMax, def: intDef, designScreenName: designScreenName)
    }
    
    override func mapToValue(_ geneValue: Int) -> CGFloat! {
        return CGFloat(geneValue) * step
    }
    
    override func mapValueToInt(_ value: CGFloat) -> Int! {
        return Int(round(value / step))
    }
}
