//
//  SpawnScreen.swift
//  MPCGD
//
//  Created by Simon Colton on 28/05/2017.
//  Copyright © 2017 ThoseMetamakers. All rights reserved.
//

import Foundation
import SpriteKit

class SpawnScreen: HKComponent{
    
    var rateSlider: HKSlider
    
    var rateLabel: SKLabelNode
    
    init(size: CGSize){
        rateSlider = HKSlider(size: CGSize(width: size.width * 0.46, height: 50))
        rateSlider.maximumValue = Float(MPCGDGenome.spawnRates.count - 1)
        rateSlider.minimumValue = 0
        rateSlider.position = CGPoint(x: -size.width/6, y: -112)
        rateLabel = SKLabelNode(text: "")
        rateLabel.fontColor = Colours.getColour(.antiqueWhite)
        rateLabel.fontName = "Helvetica Neue Thin"
        rateLabel.fontSize = 17
        rateLabel.horizontalAlignmentMode = .right
        rateLabel.position = CGPoint(x: rateSlider.size.width/2, y: 30)
        super.init()
        let l = SKLabelNode(text: "Rate:")
        l.horizontalAlignmentMode = .left
        l.position = CGPoint(x: -rateSlider.size.width/2, y: 30)
        l.fontName = "Helvetica Neue Thin"
        l.fontSize = 17
        l.fontColor = Colours.getColour(.antiqueWhite)
        rateSlider.addChild(l)
        rateSlider.addChild(rateLabel)
        rateSlider.isUserInteractionEnabled = false
        addChild(rateSlider)
        rateSlider.onDragCode = { [unowned self] () -> () in
            let pos = Int(round(self.rateSlider.value))
            self.rateLabel.text = "\(MPCGDGenome.spawnRates[pos])"
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func closeDown(){
        rateSlider.isUserInteractionEnabled = false
    }
    
    func initialiseFromMPCGDGenome(rate: Int){
        rateSlider.value = Float(rate)
        rateLabel.text = "\(MPCGDGenome.spawnRates[rate])"
        rateSlider.isUserInteractionEnabled = true
    }
    
}
