//
//  ChoiceGene.swift
//  Engine
//
//  Created by Simon Colton on 09/10/2015.
//  Copyright © 2018 ThoseMetamakers. All rights reserved.
//

import Foundation
import SpriteKit

/// A gene offering a choice of options
class ChoiceGene<ChoiceType: Equatable> : Gene<ChoiceType> {
    let choices: [ChoiceType]
    
    init(name: String, choices: [ChoiceType], def: ChoiceType, designScreenName: DesignScreenName) {
        self.choices = choices
        let defIndex = choices.index(of: def)!
        super.init(name: name, min: 0, max: choices.count-1, def: defIndex, designScreenName: designScreenName)
    }
    
    @available(*, deprecated: 1.0, message: "Use EnumGene instead")
    init(name: String, mapping: (Int) -> ChoiceType?, def: ChoiceType, designScreenName: DesignScreenName) {
        var choices: [ChoiceType] = []
        var i = 0
        while let value = mapping(i) {
            choices.append(value)
            i += 1
        }
        
        self.choices = choices
        let defIndex = choices.index(of: def)!
        super.init(name: name, min: 0, max: choices.count-1, def: defIndex, designScreenName: designScreenName)
    }
    
    override func mapToValue(_ geneValue: Int) -> ChoiceType! {
        if geneValue >= 0 && geneValue < choices.count {
            return choices[geneValue]
        }
        else {
            return nil
        }
    }
    
    override func mapValueToInt(_ value: ChoiceType) -> Int! {
        return choices.index(of: value)
    }
    
    override func parseJsonObjectToIntValue(_ ob: AnyObject) -> Int? {
        if let string = ob as? String {
            for choiceNum in 0 ..< choices.count {
                if "\(choices[choiceNum])" == string {
                    return choiceNum
                }
            }
        }
        else if let number = ob as? NSNumber {
            for choiceNum in 0 ..< choices.count {
                if choices[choiceNum] as? NSNumber == number {
                    return choiceNum
                }
            }
        }
        
        return nil
    }
}
