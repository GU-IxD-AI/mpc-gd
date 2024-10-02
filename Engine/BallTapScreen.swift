//
//  TapOptionsScreen.swift
//  MPCGD
//
//  Created by Simon Colton on 21/04/2017.
//  Copyright © 2017 Simon Colton. All rights reserved.
//

import Foundation
import SpriteKit

class BallTapScreen: HKComponent{
    
    let tapScoreSlider: HKSlider
    
    let tapScoreValueLabel: SKLabelNode
    
    let tapScoreLabel: SKLabelNode
    
    init(size: CGSize){
        tapScoreLabel = SKLabelNode(text: "Tap score:")
        tapScoreLabel.horizontalAlignmentMode = .left
        tapScoreLabel.fontName = "Helvetica Neue Thin"
        tapScoreLabel.fontSize = 17
        tapScoreLabel.position = CGPoint(x: -size.width/2 + 10, y: -80)
        tapScoreLabel.fontColor = Colours.getColour(.antiqueWhite)

        tapScoreValueLabel = SKLabelNode(text: "")
        tapScoreValueLabel.horizontalAlignmentMode = .right
        tapScoreValueLabel.fontName = "Helvetica Neue Thin"
        tapScoreValueLabel.fontSize = 17
        tapScoreValueLabel.position = CGPoint(x: (size.width * 0.25) - 30, y: -80)
        tapScoreValueLabel.fontColor = Colours.getColour(.antiqueWhite)
        
        tapScoreSlider = HKSlider(size: CGSize(width: size.width * 0.5, height: 50))
        tapScoreSlider.maximumValue = 61
        tapScoreSlider.minimumValue = 0
        tapScoreSlider.position = CGPoint(x: -40, y: -110)
        
        super.init()
        
        addChild(tapScoreLabel)
        addChild(tapScoreValueLabel)
        addChild(tapScoreSlider)
        
        tapScoreSlider.onDragCode = { [unowned self] () -> () in
            let pos = Int(round(self.tapScoreSlider.value))
            let tapScore = MPCGDGenome.tapScores[pos]
            self.tapScoreValueLabel.text = (tapScore == -90) ? MPCGDGenome.deathSymbol : "\(tapScore)"
        }
        tapScoreSlider.addDeathSymbolOnLeft()
    }
    
    func initialiseFromMPCGDGenome(_ mpcgdGenome: MPCGDGenome, tapScore: Int){
        tapScoreSlider.isUserInteractionEnabled = true
        tapScoreSlider.value = Float(MPCGDGenome.tapScores.index(of: tapScore)!)
        tapScoreValueLabel.text = (tapScore == -90) ? MPCGDGenome.deathSymbol : "\(tapScore)"
    }
    
    func closeDown(){
        tapScoreSlider.isUserInteractionEnabled = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
