//
//  ColourGene.swift
//  Engine
//
//  Created by Simon Colton on 09/10/2015.
//  Copyright © 2015 Simon Colton. All rights reserved.
//

import Foundation
import SpriteKit

/// A gene offering a choice of colours
class ColourGene : ChoiceGene<UIColor> {
    init(name: String, def: ColourNames, designScreenName: DesignScreenName) {
        let defColour = Colours.getColour(def) // this also forces the colours to be loaded from disk
        super.init(name: name, choices: Colours.colours, def: defColour, designScreenName: designScreenName)
    }
    
    var valueAsString : String {
        return Colours.colourNames[intValue]
    }
    
    override func parseJsonObjectToIntValue(_ ob: AnyObject) -> Int? {
        if let name = ob as? String {
            return Colours.colourNames.index(of: name)
        }
        else {
            return nil
        }
    }
}
