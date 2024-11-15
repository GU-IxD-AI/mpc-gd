//
//  BallCollisionScreen.swift
//  MPCGD
//
//  Created by Simon Colton on 17/04/2017.
//  Copyright © 2017 ThoseMetamakers. All rights reserved.
//

import Foundation
import SpriteKit

class ControllerCollisionsScreen : HKComponent{
    
    let l1: SKLabelNode
    
    let l2: SKLabelNode
    
    let whiteScoreSlider: HKSlider
    
    let whiteScoreLabel: SKLabelNode
    
    let blueScoreSlider: HKSlider
    
    let blueScoreLabel: SKLabelNode
    
    init(size: CGSize){

        whiteScoreSlider = HKSlider(size: CGSize(width: size.width * 0.5, height: 50))
        whiteScoreSlider.maximumValue = 61
        whiteScoreSlider.minimumValue = 0
        whiteScoreSlider.position = CGPoint(x: -40, y: 60)
        
        blueScoreSlider = HKSlider(size: CGSize(width: size.width * 0.5, height: 50))
        blueScoreSlider.maximumValue = 61
        blueScoreSlider.minimumValue = 0
        blueScoreSlider.position = CGPoint(x: -40, y: -28)
        
        l1 = SKLabelNode(text: "")
        l1.fontName = "Helvetica Neue Thin"
        l1.fontSize = 18
        l1.position = CGPoint(x: (-size.width * 0.5) + 10, y: 95)
        l1.horizontalAlignmentMode = .left
        l1.fontColor = Colours.getColour(.antiqueWhite)
        l1.horizontalAlignmentMode = .left
        
        whiteScoreLabel = SKLabelNode(text: "")
        whiteScoreLabel.fontName = "Helvetica Neue Thin"
        whiteScoreLabel.fontSize = 18
        whiteScoreLabel.position = CGPoint(x: (size.width * 0.25) - 30, y: 95)
        whiteScoreLabel.horizontalAlignmentMode = .right
        whiteScoreLabel.fontColor = Colours.getColour(.antiqueWhite)
        
        l2 = SKLabelNode(text: "")
        l2.fontName = "Helvetica Neue Thin"
        l2.fontSize = 17
        l2.position = CGPoint(x: (-size.width * 0.5) + 10, y: 5)
        l2.horizontalAlignmentMode = .left
        l2.fontColor = Colours.getColour(.antiqueWhite)
        
        blueScoreLabel = SKLabelNode(text: "")
        blueScoreLabel.fontName = "Helvetica Neue Thin"
        blueScoreLabel.fontSize = 17
        blueScoreLabel.position = CGPoint(x: (size.width * 0.25) - 30, y: 5)
        blueScoreLabel.horizontalAlignmentMode = .right
        blueScoreLabel.fontColor = Colours.getColour(.antiqueWhite)
        
        super.init()
        
        addChild(l1)
        addChild(whiteScoreSlider)
        addChild(whiteScoreLabel)
        
        addChild(l2)
        addChild(blueScoreSlider)
        addChild(blueScoreLabel)
        
        whiteScoreSlider.onDragCode = { [unowned self] () -> () in
            let pos = Int(round(self.whiteScoreSlider.value))
            let collisionScore = MPCGDGenome.collisionScores[pos]
            self.whiteScoreLabel.text = collisionScore == -90 ? MPCGDGenome.deathSymbol : "\(collisionScore)"
        }
        blueScoreSlider.onDragCode = { [unowned self] () -> () in
            let pos = Int(round(self.blueScoreSlider.value))
            let collisionScore = MPCGDGenome.collisionScores[pos]
            self.blueScoreLabel.text = collisionScore == -90 ? MPCGDGenome.deathSymbol : "\(collisionScore)"
        }
        whiteScoreSlider.addDeathSymbolOnLeft()
        blueScoreSlider.addDeathSymbolOnLeft()
    }
    
    func initialiseFromMPCGDGenome(_ mpcgdGenome: MPCGDGenome, whiteCharName: String, blueCharName: String){
        l1.text = "\(whiteCharName) score:"
        whiteScoreSlider.isUserInteractionEnabled = true
        whiteScoreSlider.value = Float(MPCGDGenome.collisionScores.index(of: mpcgdGenome.whiteControllerCollisionScore)!)
        whiteScoreLabel.text = mpcgdGenome.whiteControllerCollisionScore == -90 ? MPCGDGenome.deathSymbol : "\(mpcgdGenome.whiteControllerCollisionScore)"
        
        l2.text = "\(blueCharName) score:"
        blueScoreSlider.isUserInteractionEnabled = true
        blueScoreSlider.value = Float(MPCGDGenome.collisionScores.index(of: mpcgdGenome.blueControllerCollisionScore)!)
        
        blueScoreLabel.text = mpcgdGenome.blueControllerCollisionScore == -90 ? MPCGDGenome.deathSymbol : "\(mpcgdGenome.blueControllerCollisionScore)"
    }

    func closeDown(){
        whiteScoreSlider.isUserInteractionEnabled = false
        blueScoreSlider.isUserInteractionEnabled = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
