//
//  HKTextButton.swift
//  MPCGD
//
//  Created by Simon Colton on 05/01/2017.
//  Copyright © 2017 Simon Colton. All rights reserved.
//

import Foundation
import SpriteKit

class HKTextButton: HKComponent{
    
    var tapCode: (() -> ())! = nil
    
    var textNode: SKLabelNode!
    
    var isAnimating = false
    
    var tapNode: SKSpriteNode
    
    fileprivate let scaleAction = SKAction.sequence([HKEasing.scaleTo(1.15, duration: 0.1, easingFunction: BackEaseOut), HKEasing.scaleTo(1.0, duration: 0.1, easingFunction: BackEaseOut), SKAction.wait(forDuration: 0.1)])
    
    init(text: String, font: UIFont, colour: UIColor){
        textNode = SKLabelNode(font, colour)
        textNode.text = text
        tapNode = SKSpriteNode()
        let size = FontUtils.textSize(text, font: font)
        tapNode.size = size * 2
        super.init()
        addChild(textNode)
        addChild(tapNode)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !isAnimating && touches.count == 1{
            if let touch = touches.first{
                if touch.tapCount <= 1{
                    isAnimating = true
                    textNode.run(scaleAction, completion: {
                        self.isAnimating = false
                        if self.tapCode != nil{
                            self.tapCode()
                        }
                    })
                }
            }
        }
    }

    
}
