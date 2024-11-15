//
//  ZoneScoreScreen.swift
//  MPCGD
//
//  Created by Simon Colton on 30/05/2017.
//  Copyright © 2017 ThoseMetamakers. All rights reserved.
//

import Foundation
import SpriteKit

class ZoneScoreScreen: HKComponent{
    
    var scoreSlider: HKSlider
    
    var scoreLabel: SKLabelNode
    
    init(size: CGSize){

        scoreSlider = HKSlider(size: CGSize(width: size.width * 0.8, height: 50))
        scoreSlider.position = CGPoint(x: 0, y: -112)
        scoreSlider.isUserInteractionEnabled = false
        scoreSlider.minimumValue = Float(0)
        scoreSlider.maximumValue = Float(MPCGDGenome.zoneScores.count - 1)
        
        scoreLabel = SKLabelNode(text: "")
        scoreLabel.fontName = "Helvetica Neue Thin"
        scoreLabel.fontSize = 20
        scoreLabel.fontColor = Colours.getColour(.antiqueWhite)
        scoreLabel.horizontalAlignmentMode = .right
        scoreLabel.position = CGPoint(x: size.width/2 - 25, y: 30)
        
        let l = SKLabelNode(text: "Score:")
        l.fontName = "Helvetica Neue Thin"
        l.fontSize = 20
        l.fontColor = Colours.getColour(.antiqueWhite)
        l.horizontalAlignmentMode = .left
        l.position = CGPoint(x: -size.width/2 + 25, y: 30)
    
        super.init()
        addChild(scoreSlider)
        scoreSlider.addChild(l)
        scoreSlider.addChild(scoreLabel)
        
        scoreSlider.onDragCode = { [unowned self] () -> () in
            let s = MPCGDGenome.zoneScores[Int(round(self.scoreSlider.value))]
            self.scoreLabel.text = (s == -90) ? MPCGDGenome.deathSymbol : "\(s)"
        }
        scoreSlider.addDeathSymbolOnLeft()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func closeDown(){
        scoreSlider.isUserInteractionEnabled = false
    }
    
    func initialiseFromMPCGDGenome(score: Int){
        scoreSlider.value = Float(MPCGDGenome.zoneScores.index(of: score)!)
        scoreLabel.text = (score == -90) ? MPCGDGenome.deathSymbol : "\(score)"
        scoreSlider.isUserInteractionEnabled = true
    }
    

}
