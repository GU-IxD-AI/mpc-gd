//
//  EnumGene.swift
//  Engine
//
//  Created by Powley, Edward on 05/02/2016.
//  Copyright © 2016 ThoseMetamakers. All rights reserved.
//

import Foundation

class EnumGene<ChoiceType: Equatable & RawRepresentable> : ChoiceGene<ChoiceType> {
    
    init(name: String, def: ChoiceType, designScreenName: DesignScreenName) {
        var choices: [ChoiceType] = []
        var i = 0
        while let value = ChoiceType(rawValue: i as! ChoiceType.RawValue) {
            choices.append(value)
            i += 1
        }
        
        super.init(name: name, choices: choices, def: def, designScreenName: designScreenName)
    }
}
