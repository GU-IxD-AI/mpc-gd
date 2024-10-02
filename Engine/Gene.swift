//
//  Gene.swift
//  Fask
//
//  Created by Powley, Edward on 01/10/2015.
//  Copyright © 2015 Simon Colton. All rights reserved.
//

import Foundation
import SpriteKit


/// Generic class for gene types. Do not use this directly.
class Gene<ValueType> : GeneBase {
    var value: ValueType {
        get {
            return mapToValue(intValue)!
        }
    }
    
    override init(name: String, min: Int, max: Int, def: Int, designScreenName: DesignScreenName) {
        super.init(name: name, min: min, max: max, def: def, designScreenName: designScreenName)
    }
    
    func mapToValue(_ geneValue: Int) -> ValueType! {
        assertionFailure("mapToValue must be overridden")
        return nil
    }
    
    func mapValueToInt(_ value: ValueType) -> Int! {
        assertionFailure("mapToValue must be overridden")
        return nil
    }
    
    override func parseJsonObjectToIntValue(_ ob: AnyObject) -> Int? {
        if let v = ob as? ValueType {
            return mapValueToInt(v)
        }
        else {
            return nil
        }
    }
}
