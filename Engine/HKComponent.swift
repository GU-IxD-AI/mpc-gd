//
//  HKComponent.swift
//  HUDKitDemo
//
//  Created by Saunders, Rob on 02/11/2016.
//  Copyright © 2016 Saunders, Rob. All rights reserved.
//

import SpriteKit

// TODO: Add definitions for different states

// Base class for all HUDKit components

protocol HKAnimatedComponent{
    
    func updateAfterValuesChanged()
    
}

var HKDisableUserInteractions = false

class HKComponent: SKNode {
    
    var dragStartedHere = false

    override init() {
        // TODO: Do something...
        super.init()
        isUserInteractionEnabled = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("Fatal Error: init(coder) not implemented!")
    }

    /*
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        print("\(name) HK COMP TOUCHED")
    }
 */
}
