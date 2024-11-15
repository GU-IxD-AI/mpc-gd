//
//  GameEndingsScreen.swift
//  MPCGD
//
//  Created by Simon Colton on 06/04/2017.
//  Copyright © 2017 ThoseMetamakers. All rights reserved.
//

import Foundation
import SpriteKit

class GameEndingsScreen : HKComponent{
    
    let winningPointsSlider: HKSlider
    
    let gameDurationSlider: HKSlider
    
    let livesSlider: HKSlider
    
    var mpcgdGenome: MPCGDGenome! = nil
    
    var winningPointsLabel: SKLabelNode! = nil
    
    var gameDurationLabel: SKLabelNode! = nil
    
    var livesLabel: SKLabelNode! = nil
    
    init(size: CGSize){
        winningPointsSlider = HKSlider(size: CGSize(width: size.width * 0.8, height: 50))
        winningPointsSlider.maximumValue = 61
        winningPointsSlider.minimumValue = 0
        winningPointsSlider.position = CGPoint(x: 0, y: 63)
        gameDurationSlider = HKSlider(size: CGSize(width: size.width * 0.8, height: 50))
        gameDurationSlider.maximumValue = 61
        gameDurationSlider.minimumValue = 0
        gameDurationSlider.position = CGPoint(x: 0, y: -25)
        livesSlider = HKSlider(size: CGSize(width: size.width * 0.46, height: 50))
        livesSlider.maximumValue = 9
        livesSlider.minimumValue = 0
        livesSlider.position = CGPoint(x: -size.width/6, y: -112)
        super.init()

        winningPointsLabel = getLabel("")
        winningPointsLabel.position = CGPoint(x: 40, y: 93)
        winningPointsLabel.horizontalAlignmentMode = .left
        gameDurationLabel = getLabel("")
        gameDurationLabel.position = CGPoint(x: 40, y: 5)
        gameDurationLabel.horizontalAlignmentMode = .left
        livesLabel = getLabel("")
        livesLabel.position = CGPoint(x: -20, y: -82)
        livesLabel.horizontalAlignmentMode = .left
        let label1 = getLabel("Points for win:")
        label1.position = CGPoint(x: 20, y: 93)
        let label2 = getLabel("Game ends at:")
        label2.position = CGPoint(x: 20, y: 5)
        let label3 = getLabel("Lives:")
        label3.position = CGPoint(x: -40, y: -82)
        label1.horizontalAlignmentMode = .right
        label2.horizontalAlignmentMode = .right
        label3.horizontalAlignmentMode = .right
        
        addChild(winningPointsSlider)
        addChild(gameDurationSlider)
        addChild(livesSlider)
        addChild(winningPointsLabel)
        addChild(gameDurationLabel)
        addChild(livesLabel)
        addChild(label1)
        addChild(label2)
        addChild(label3)
        winningPointsSlider.onDragCode = { [unowned self] () -> () in
            let pTW = MPCGDGenome.winningScores[Int(round(self.winningPointsSlider.value))]
            self.winningPointsLabel.text = pTW == 0 ? "Off" : "\(pTW)"
        }
        gameDurationSlider.onDragCode = { [unowned self] () -> () in
            let gD = MPCGDGenome.gameDurations[Int(round(self.gameDurationSlider.value))]
            self.gameDurationLabel.text = gD == 0 ? "Off" : "\(gD)s"
        }
        livesSlider.onDragCode = { [unowned self] () -> () in
            self.livesLabel.text = self.livesSlider.value == 0 ? "Off" : "\(Int(round(self.livesSlider.value)))"
        }
        winningPointsSlider.addOffSymbolOnLeft()
        gameDurationSlider.addOffSymbolOnLeft()
        livesSlider.addOffSymbolOnLeft()
    }
    
    func getLabel(_ text: String) -> SKLabelNode{
        let font = UIFontCache(name: "HelveticaNeue-Thin", size: 20)
        let label = SKLabelNode(font, Colours.getColour(.antiqueWhite))
        label.text = text
        return label
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func closeDown(){
        winningPointsSlider.isUserInteractionEnabled = false
        gameDurationSlider.isUserInteractionEnabled = false
        livesSlider.isUserInteractionEnabled = false
    }
    
    func initialiseFromMPCGDGenome(_ mpcgdGenome: MPCGDGenome){
        let wPSPos = MPCGDGenome.winningScores.index(of: mpcgdGenome.pointsToWin)!
        winningPointsSlider.value = Float(wPSPos)
        let gDSPos = MPCGDGenome.gameDurations.index(of: mpcgdGenome.gameDuration)!
        gameDurationSlider.value = Float(gDSPos)
        winningPointsSlider.isUserInteractionEnabled = true
        gameDurationSlider.isUserInteractionEnabled = true
        livesSlider.isUserInteractionEnabled = true
        let pTW = MPCGDGenome.winningScores[wPSPos]
        winningPointsLabel.text = pTW == 0 ? "Off" : "\(pTW) "
        let gD = MPCGDGenome.gameDurations[gDSPos]
        gameDurationLabel.text = gD == 0 ? "Off" : "\(gD)s"
        livesSlider.value = Float(mpcgdGenome.numLives)
        livesLabel.text = mpcgdGenome.numLives == 0 ? "Off" : "\(mpcgdGenome.numLives)"
    }

}
