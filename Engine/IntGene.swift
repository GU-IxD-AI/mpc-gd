//
//  IntGene.swift
//  Engine
//
//  Created by Simon Colton on 09/10/2015.
//  Copyright © 2018 ThoseMetamakers. All rights reserved.
//

import Foundation

/// A gene of integer type
class IntGene : Gene<Int> {
    override init(name: String, min: Int, max: Int, def: Int, designScreenName: DesignScreenName) {
        super.init(name: name, min: min, max: max, def: def, designScreenName: designScreenName)
    }
    
    override func mapToValue(_ geneValue: Int) -> Int! {
        return geneValue
    }
    
    override func mapValueToInt(_ value: Int) -> Int! {
        return value
    }
}
