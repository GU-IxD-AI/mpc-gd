//
//  SKRoundButtonNode.swift
//  Fask
//
//  Created by Simon Colton on 30/09/2015.
//  Copyright © 2015 Simon Colton. All rights reserved.
//

import Foundation
import SpriteKit


class SKRoundButtonNode: SKSpriteNode{
    
    func setImage(_ image: UIImage){
        texture = SKTexture(image: image)
    }
    
    func highlight(_ duration: TimeInterval){
        setAlphaValue(0.1)
        performAction(SKAction.fadeAlpha(to: 1.0, duration: duration))
    }
}
