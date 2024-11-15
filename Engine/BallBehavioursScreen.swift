//
//  BallBehavioursScreen.swift
//  MPCGD
//
//  Created by Simon Colton on 20/03/2017.
//  Copyright © 2017 ThoseMetamakers. All rights reserved.
//

import Foundation
import SpriteKit

class BallBehavioursScreen: HKComponent{
    
    let speedSlider: HKSlider
    
    let bounceSlider: HKSlider
    
    let noiseSlider: HKSlider
    
    var speedValueNode: SKLabelNode! = nil
    
    var bounceValueNode: SKLabelNode! = nil
    
    var noiseValueNode: SKLabelNode! = nil
    
    var ball1SpriteNode: SKSpriteNode! = nil

    var ball2SpriteNode: SKSpriteNode! = nil
    
    var ball3SpriteNode: SKSpriteNode! = nil
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(size: CGSize){
        speedSlider = HKSlider(size: CGSize(width: size.width * 0.68, height: 50))
        bounceSlider = HKSlider(size: CGSize(width: size.width * 0.68, height: 50))
        noiseSlider = HKSlider(size: CGSize(width: size.width * 0.68, height: 50))
        speedSlider.minimumValue = 1
        speedSlider.maximumValue = 9
        bounceSlider.minimumValue = 0
        bounceSlider.maximumValue = 8
        noiseSlider.minimumValue = 0
        noiseSlider.maximumValue = 8
        super.init()
        speedValueNode = getValueLabel()
        bounceValueNode = getValueLabel()
        noiseValueNode = getValueLabel()
        addChild(speedValueNode)
        addChild(bounceValueNode)
        addChild(noiseValueNode)
        addChild(speedSlider)
        addChild(bounceSlider)
        addChild(noiseSlider)
        speedSlider.position.x = 20
        bounceSlider.position.x = 20
        noiseSlider.position.x = 20
        speedSlider.position.y = 89
        noiseSlider.position.y = 29
        bounceSlider.position.y = -31
        speedSlider.zPosition += 10000
        bounceSlider.zPosition += 10000
        noiseSlider.zPosition += 10000
        addLabel("speed:", slider: speedSlider, iconName: "Speed", valueNode: speedValueNode, iconX: -90)
        addLabel("randomness:", slider: noiseSlider, iconName: "Noise", valueNode: noiseValueNode, iconX: -107)
        addLabel("bounce:", slider: bounceSlider, iconName: "Bounce", valueNode: bounceValueNode, iconX: -107)
        speedSlider.onDragCode = { [unowned self] () -> () in
            self.speedValueNode.text = "\(Int(round(self.speedSlider.value)))"
        }
        bounceSlider.onDragCode = { [unowned self] () -> () in
            self.bounceValueNode.text = "\(Int(round(self.bounceSlider.value)))"
        }
        noiseSlider.onDragCode = { [unowned self] () -> () in
            self.noiseValueNode.text = "\(Int(round(self.noiseSlider.value)))"
        }
        ball1SpriteNode = SKSpriteNode()
        ball2SpriteNode = SKSpriteNode()
        ball3SpriteNode = SKSpriteNode()
        ball1SpriteNode.size = CGSize(width: 17, height: 17)
        ball2SpriteNode.size = CGSize(width: 17, height: 17)
        ball3SpriteNode.size = CGSize(width: 17, height: 17)
        ball1SpriteNode.position = CGPoint(x: -107, y: 89)
        ball2SpriteNode.position = CGPoint(x: -93, y: 40)
        ball3SpriteNode.position = CGPoint(x: -90, y: -21)
        ball1SpriteNode.zPosition = speedSlider.zPosition + 1
        ball2SpriteNode.zPosition = noiseSlider.zPosition + 1
        ball3SpriteNode.zPosition = bounceSlider.zPosition + 1
        addChild(ball1SpriteNode)
        addChild(ball2SpriteNode)
        addChild(ball3SpriteNode)
    }
    
    func getValueLabel() -> SKLabelNode{
        let font = UIFontCache(name: "HelveticaNeue-Thin", size: 20)
        let labelNode = SKLabelNode(font, Colours.getColour(.antiqueWhite))
        labelNode.text = "0"
        return labelNode
    }
    
    func addLabel(_ text: String, slider: HKSlider, iconName: String, valueNode: SKLabelNode, iconX: CGFloat){
        let iconNode = SKSpriteNode(imageNamed: iconName)
        addChild(iconNode)
        iconNode.position = CGPoint(x: iconX, y: slider.position.y)
        let font = UIFontCache(name: "HelveticaNeue-Thin", size: 20)
        let labelNode = SKLabelNode(font,  Colours.getColour(.antiqueWhite))
        labelNode.text = text
        labelNode.position.y = slider.position.y + 20
        labelNode.position.x = 40
        labelNode.horizontalAlignmentMode = .right
        valueNode.position.x = 43
        valueNode.position.y = slider.position.y + 20
        valueNode.horizontalAlignmentMode = .left
        addChild(labelNode)
    }
    
    func initialiseFromMPCGDGenome(_ MPCGDGenome: MPCGDGenome, speed: Int, noise: Int, bounce: Int, charType: String){
        speedSlider.isUserInteractionEnabled = true
        bounceSlider.isUserInteractionEnabled = true
        noiseSlider.isUserInteractionEnabled = true
        speedSlider.value = Float(speed)
        bounceSlider.value = Float(bounce)
        noiseSlider.value = Float(noise)
        speedValueNode.text = "\(speed)"
        bounceValueNode.text = "\(bounce)"
        noiseValueNode.text = "\(noise)"
        let collectionNum = (charType == "White") ? MPCGDGenome.whiteBallCollection : MPCGDGenome.blueBallCollection
        let characterNum = (charType == "White") ? MPCGDGenome.whiteBallChoice : MPCGDGenome.blueBallChoice
        let imageName = CharacterIconHandler.getCharacterName(collectionNum: collectionNum, characterNum: characterNum)
        let image = PDFImage(named: imageName, size: CGSize(width: 17, height: 17))!
        ball1SpriteNode.texture = SKTexture(image: image)
        ball2SpriteNode.texture = SKTexture(image: image)
        ball3SpriteNode.texture = SKTexture(image: image)
    }
    
    func closeDown(){
        speedSlider.isUserInteractionEnabled = false
        bounceSlider.isUserInteractionEnabled = false
        noiseSlider.isUserInteractionEnabled = false
    }
    
}
