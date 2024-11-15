//
//  BallChoiceScreen.swift
//  MPCGD
//
//  Created by Simon Colton on 28/02/2017.
//  Copyright © 2017 ThoseMetamakers. All rights reserved.
//

import Foundation
import SpriteKit

class BallChoiceScreen: HKComponent{
    
    let slider1: HKSlider
    
    let slider2: HKSlider
    
    var label1 = SKLabelNode(text: "")
    
    var label2 = SKLabelNode(text: "")
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(size: CGSize){
        let xOffset = size.width/6 - 2
        slider1 = HKSlider(size: CGSize(width: size.width * 0.51, height: 50))
        slider2 = HKSlider(size: CGSize(width: size.width * 0.51, height: 50))
        slider1.maximumValue = 30
        slider2.maximumValue = 30
        slider1.position = CGPoint(x: xOffset, y: 60)
        slider2.position = CGPoint(x: xOffset, y: -28)
        super.init()
        addChild(slider1)
        addChild(slider2)
        addXLabel(CGPoint(x: xOffset - 5, y: 100))
        addXLabel(CGPoint(x: xOffset - 5, y: 12))
        
        label1.fontName = "Helvetica Neue Thin"
        label1.fontSize = 22
        label1.position = CGPoint(x: xOffset - 5, y: 100)
        label1.fontColor = Colours.getColour(.antiqueWhite)
        label1.verticalAlignmentMode = SKLabelVerticalAlignmentMode.center
        label1.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        addChild(label1)

        label2.fontName = "Helvetica Neue Thin"
        label2.fontSize = 22
        label2.position = CGPoint(x: xOffset - 5, y: 12)
        label2.fontColor = Colours.getColour(.antiqueWhite)
        label2.verticalAlignmentMode = SKLabelVerticalAlignmentMode.center
        label2.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        slider1.onDragCode = { [unowned self] () -> () in
            self.label1.text = "\(Int(round(self.slider1.value)))"
        }
        slider2.onDragCode = { [unowned self] () -> () in
            self.label2.text = "\(Int(round(self.slider2.value)))"
        }
        // HACKFIX!!!
        slider1.zPosition += 10000
        slider2.zPosition += 10000

        addChild(label2)
    }
    
    func updateLabels(){
        label1.text = "\(Int(round(slider1.value)))"
        label2.text = "\(Int(round(slider2.value)))"
    }
    
    func addXLabel(_ position: CGPoint){
        let label1 = SKLabelNode(text: "x")
        label1.fontName = "Helvetica Neue Thin"
        label1.fontSize = 22
        label1.position = position
        label1.fontColor = Colours.getColour(.antiqueWhite)
        label1.verticalAlignmentMode = SKLabelVerticalAlignmentMode.center
        label1.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.right
        addChild(label1)
    }
    
    func initialiseFromMPCGDGenome(_ MPCGDGenome: MPCGDGenome){
        slider1.value = Float(MPCGDGenome.whiteMaxOnScreen)
        slider2.value = Float(MPCGDGenome.blueMaxOnScreen)
        slider1.isUserInteractionEnabled = true
        slider2.isUserInteractionEnabled = true
        label1.text = "\(MPCGDGenome.whiteMaxOnScreen)"
        label2.text = "\(MPCGDGenome.blueMaxOnScreen)"
    }
    
    func closeDown(){
        slider1.isUserInteractionEnabled = false
        slider2.isUserInteractionEnabled = false
    }
    
    
}
