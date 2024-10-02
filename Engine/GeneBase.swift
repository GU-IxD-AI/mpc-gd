//
//  GeneBase.swift
//  Engine
//
//  Created by Simon Colton on 09/10/2015.
//  Copyright © 2015 Simon Colton. All rights reserved.
//

import Foundation
import SpriteKit

/// Base class for all gene types
class GeneBase {
    weak var chromosome: Chromosome! = nil
    var geneIndex: Int = -1
    var name: String
    let intMin: Int
    let intMax: Int
    let intDef: Int
    var hiddenFromUser = false
    var designScreenName: DesignScreenName
    var genesToUpdateOnChange : [String] = []
    
    var intValue: Int {
        get {
            return chromosome!.genes[geneIndex]
        }
        set {
            chromosome!.genes[geneIndex] = newValue
        }
    }
    
    init(name: String, min: Int, max: Int, def: Int, designScreenName: DesignScreenName) {
        assert(min <= max, "min must be less than or equal to max")
        assert(def >= min && def <= max, "def must be between min and max")
        
        self.name = name
        self.intMin = min
        self.intMax = max
        self.intDef = def
        self.designScreenName = designScreenName
    }
    
    func parseJsonObjectToIntValue(_ ob : AnyObject) -> Int? {
        return ob as? Int
    }
    
    func displayIntValue(_ intValue: Int) -> String {
        return "\(intValue)"
    }
}
