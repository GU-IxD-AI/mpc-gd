//
//  BoolGene.swift
//  Engine
//
//  Created by Simon Colton on 09/10/2015.
//  Copyright © 2018 ThoseMetamakers. All rights reserved.
//

import Foundation
import SpriteKit

/// A gene of boolean type
class BoolGene : Gene<Bool> {
    let falseText: String
    let trueText: String
    
    init(name: String, falseText: String, trueText: String, def: Bool, designScreenName: DesignScreenName) {
        self.falseText = falseText
        self.trueText = trueText
        super.init(name: name, min: 0, max: 1, def: def ? 1 : 0, designScreenName: designScreenName)
    }
    
    convenience init(name: String, def: Bool, designScreenName: DesignScreenName) {
        self.init(name: name, falseText: "no", trueText: "yes", def: def, designScreenName: designScreenName)
    }
    
    override func mapToValue(_ geneValue: Int) -> Bool! {
        return geneValue != 0
    }
    
    override func mapValueToInt(_ value: Bool) -> Int! {
        return value ? 1 : 0
    }
    
    override func parseJsonObjectToIntValue(_ ob: AnyObject) -> Int? {
        if let boolValue = ob as? Bool {
            return boolValue ? 1 : 0
        }
        else {
            return nil
        }
    }
}
