//
//  VolumesScreen.swift
//  MPCGD
//
//  Created by Simon Colton on 20/05/2017.
//  Copyright © 2017 Simon Colton. All rights reserved.
//

import Foundation
import SpriteKit

class VolumesScreen: HKComponent{
    
    var soundtrackVolumeSlider: HKSlider!
    
    var sfxVolumeSlider: HKSlider!
    
    var soundtrackVolumeLabel: SKLabelNode!
    
    var sfxVolumeLabel: SKLabelNode!
    
    init(size: CGSize){
        soundtrackVolumeSlider = HKSlider(size: CGSize(width: size.width * 0.8, height: 50))
        soundtrackVolumeSlider.maximumValue = 30
        soundtrackVolumeSlider.minimumValue = 0
        soundtrackVolumeSlider.position = CGPoint(x: 0, y: 65)
        soundtrackVolumeSlider.isUserInteractionEnabled = false
        soundtrackVolumeLabel = SKLabelNode(text: "")
        soundtrackVolumeLabel.fontName = "Helvetica Neue Thin"
        soundtrackVolumeLabel.fontSize = 17
        soundtrackVolumeLabel.fontColor = Colours.getColour(.antiqueWhite)
        soundtrackVolumeLabel.position = CGPoint(x: size.width/2 - 14, y: 100)
        soundtrackVolumeLabel.horizontalAlignmentMode = .right
        
        let l1 = SKLabelNode(text: "Soundtrack")
        l1.fontName = "Helvetica Neue Thin"
        l1.fontSize = 17
        l1.fontColor = Colours.getColour(.antiqueWhite)
        l1.position = CGPoint(x: -size.width/2 + 40, y: 100)
        l1.horizontalAlignmentMode = .left
        let volumeNode1 = SKSpriteNode(texture: SKTexture(image: PDFImage(named: "volume", size: CGSize(width: 25, height: 25))!))
        volumeNode1.position = CGPoint(x: -size.width/2 + 23, y: 106)
        volumeNode1.colorBlendFactor = 1
        volumeNode1.color = Colours.getColour(.antiqueWhite)
        
        sfxVolumeSlider = HKSlider(size: CGSize(width: size.width * 0.8, height: 50))
        sfxVolumeSlider.maximumValue = 30
        sfxVolumeSlider.minimumValue = 0
        sfxVolumeSlider.position = CGPoint(x: 0, y: -23)
        sfxVolumeSlider.isUserInteractionEnabled = false
        sfxVolumeLabel = SKLabelNode(text: "")
        sfxVolumeLabel.fontName = "Helvetica Neue Thin"
        sfxVolumeLabel.fontSize = 17
        sfxVolumeLabel.fontColor = Colours.getColour(.antiqueWhite)
        sfxVolumeLabel.position = CGPoint(x: size.width/2 - 14, y: 11)
        sfxVolumeLabel.horizontalAlignmentMode = .right
        
        let l2 = SKLabelNode(text: "Sound effects")
        l2.fontName = "Helvetica Neue Thin"
        l2.fontSize = 17
        l2.fontColor = Colours.getColour(.antiqueWhite)
        l2.position = CGPoint(x: -size.width/2 + 40, y: 12)
        l2.horizontalAlignmentMode = .left
        let volumeNode2 = SKSpriteNode(texture: SKTexture(image: PDFImage(named: "volume", size: CGSize(width: 25, height: 25))!))
        volumeNode2.position = CGPoint(x: -size.width/2 + 23, y: 19)
        volumeNode2.colorBlendFactor = 1
        volumeNode2.color = Colours.getColour(.antiqueWhite)
        
        super.init()
        
        addChild(soundtrackVolumeSlider)
        addChild(soundtrackVolumeLabel)
        addChild(l1)
        addChild(volumeNode1)
        soundtrackVolumeSlider.onDragCode = { [unowned self] () -> () in
            self.soundtrackVolumeLabel.text = "\(Int(round(self.soundtrackVolumeSlider.value)))"
        }

        addChild(sfxVolumeSlider)
        addChild(sfxVolumeLabel)
        addChild(l2)
        addChild(volumeNode2)
        sfxVolumeSlider.onDragCode = { [unowned self] () -> () in
            self.sfxVolumeLabel.text = "\(Int(round(self.sfxVolumeSlider.value)))"
        }

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initialiseFromMPCGDGenome(MPCGDGenome: MPCGDGenome){
        soundtrackVolumeSlider.isUserInteractionEnabled = true
        soundtrackVolumeSlider.value = Float(MPCGDGenome.soundtrackMasterVolume)
        soundtrackVolumeLabel.text = "\(MPCGDGenome.soundtrackMasterVolume)"

        sfxVolumeSlider.isUserInteractionEnabled = true
        sfxVolumeSlider.value = Float(MPCGDGenome.sfxVolume)
        sfxVolumeLabel.text = "\(MPCGDGenome.sfxVolume)"
    }
    
    func closeDown(){
        soundtrackVolumeSlider.isUserInteractionEnabled = false
        sfxVolumeSlider.isUserInteractionEnabled = false
    }
}
