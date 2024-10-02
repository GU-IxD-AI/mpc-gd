//
//  HKSlider.swift
//  HUDKitDemo
//
//  Created by Saunders, Rob on 04/10/2016.
//  Copyright © 2016 Saunders, Rob. All rights reserved.
//

import SpriteKit

class HKSlider : HKComponent {
    
    var touchEndCode: (() -> ())! = nil
    
    var onDragCode: (() -> ())! = nil
    
    var labelNode: SKLabelNode! = nil
    
    var lhLabelNode: SKLabelNode! = nil
    
    var rhLabelNode: SKLabelNode! = nil
    
    var lhImageNode: SKSpriteNode! = nil
    
    var rhImageNode: SKSpriteNode! = nil
    
    var value : Float = 25.0 {
        willSet(newValue) {
//            if newValue == value { return }
            if !dragging {
                // TODO: Figure out how to avoid handle the edge case of the thumb moving away from an end (to avoid move being immediately replaced by a rebound)
                let thumbPosition = convertValueToLocation(newValue)
                let seconds = calculateDuration(from: thumb.position.x, to: thumbPosition)
                let thumbAction = HKEasing.ease_FIXME("thumbPosition", to:thumbPosition, duration:seconds, easingFunction: BackEaseOut)
                self.run(thumbAction, withKey:"thumbMove")
            } else {
                self.removeAction(forKey: "thumbMove")
                self.removeAction(forKey: "thumbRebound")
                thumbPosition = convertValueToLocation(newValue)
            }
        }
    }
    
    var minimumValue : Float = 0.0 {
        didSet(newMinimumValue) {
            value = max(value, newMinimumValue)
        }
    }
    
    var maximumValue : Float = 100.0 {
        didSet(newMaximumValue) {
            value = min(value, newMaximumValue)
        }
    }
    
    @objc var thumbPosition: CGFloat {
        get { return thumb.position.x }
        set(newThumbPosition) {
            thumb.position.x = clamp(value: newThumbPosition, lower: minimumTrack.position.x, upper: maximumTrack.position.x)
            minimumTrack.size.width = thumb.position.x + size.width/2
            maximumTrack.size.width = size.width/2 - thumb.position.x
            if (newThumbPosition < 0 || newThumbPosition > size.width) {
                if self.action(forKey: "thumbMove") != nil {
                    self.removeAction(forKey: "thumbMove")
                    let toThumbPosition = convertValueToLocation(self.value)
                    let seconds = calculateDuration(from: thumb.position.x, to: toThumbPosition)
                    let thumbAction = HKEasing.ease_FIXME("thumbPosition", to:toThumbPosition, duration:seconds, easingFunction: BackEaseOut)
                    self.run(thumbAction, withKey:"thumbRebound")
                }
            }
        }
    }
    
    var size: CGSize {
        didSet(newSize) {
            let percent = (value - minimumValue) / (maximumValue - minimumValue)
            let newThumbPosition = CGFloat(percent) * size.width
            thumb.position.x = clamp(value: newThumbPosition, lower: 0, upper: size.width)
            minimumTrack.size.width = thumb.position.x
            maximumTrack.size.width = size.width - thumb.position.x
        }
    }
    
    fileprivate var thumb : HKImage
    fileprivate var minimumTrack : HKImage
    fileprivate var maximumTrack : HKImage
    
    fileprivate var dragging : Bool = false {
        willSet(newDragging) {
            if newDragging == dragging { return }
            thumb.removeAction(forKey: "scale")
            if newDragging {
                let scaleAction = HKEasing.scaleTo(1.2, duration:0.2, easingFunction: BackEaseOut)
                thumb.run(scaleAction, withKey: "scale")
            } else {
                let scaleAction = HKEasing.scaleTo(1.0, duration:0.2, easingFunction: BackEaseOut)
                thumb.run(scaleAction, withKey: "scale")
            }
        }
    }
    
    init(size: CGSize, label: String! = nil, lhLabel: String! = nil, rhLabel: String! = nil, lhImage: UIImage! = nil, rhImage: UIImage! = nil) {
        self.size = size
        
        let thumbImage = HKStyle.imageOfSliderHandle(selectedColor: Colours.getColour(ColourNames.steelBlue), selected: true)
        thumb = HKImage(image: thumbImage)
        thumb.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        thumb.position = CGPoint(x: -size.width/2, y: 0)
        thumb.zPosition = 100
        
        let minimumTrackImage = ImageUtils.getBlankImage(CGSize(width: size.width, height: 2), colour: Colours.getColour(.black))
        minimumTrack = HKImage(image: minimumTrackImage)
        minimumTrack.anchorPoint = CGPoint(x: 0.0, y: 0.5)
        minimumTrack.position = CGPoint(x: -size.width/2, y: 0)
        minimumTrack.zPosition = 99
        minimumTrack.colorBlendFactor = 1.0
//        minimumTrack.color = UIColor(red: 0.929, green: 0.271, blue: 0.482, alpha: 1.000)
        minimumTrack.color = Colours.getColour(ColourNames.steelBlue)
        
        let maximumTrackImage = ImageUtils.getBlankImage(CGSize(width: size.width, height: 2), colour: Colours.getColour(.black))
        maximumTrack = HKImage(image: maximumTrackImage)
        maximumTrack.anchorPoint = CGPoint(x: 1.0, y: 0.5)
        maximumTrack.position = CGPoint(x: size.width/2, y: 0)
        maximumTrack.zPosition = 99
        maximumTrack.colorBlendFactor = 1.0
        maximumTrack.color = UIColor.lightGray
        
        super.init()
        self.thumbPosition = convertValueToLocation(self.value)
        
        addChild(minimumTrack)
        addChild(maximumTrack)
        addChild(thumb)
        
        if label != nil{
            labelNode = getLabelNode(label)
            labelNode.fontSize = 17
            labelNode.verticalAlignmentMode = SKLabelVerticalAlignmentMode.baseline
            labelNode.position = CGPoint(x: 0, y: 18)
            addChild(labelNode)
        }
        
        if lhLabel != nil{
            lhLabelNode = getLabelNode(lhLabel)
            lhLabelNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.right
            lhLabelNode.position = CGPoint(x: -size.width/2 - thumbImage.size.width/2 + 7, y: 0)
            addChild(lhLabelNode)
        }
        
        if rhLabel != nil{
            rhLabelNode = getLabelNode(rhLabel)
            rhLabelNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
            rhLabelNode.position = CGPoint(x: size.width/2 + thumbImage.size.width/2 - 7, y: 0)
            addChild(rhLabelNode)
        }

        if lhImage != nil{
            lhImageNode = SKSpriteNode(texture: SKTexture(image: lhImage))
            var x = -size.width / 2;
            x = x - thumbImage.size.width / 2 + 7
            x = x - lhImage.size.width / 2
            lhImageNode.position = CGPoint(x: x, y: 0)
            addChild(lhImageNode)
        }

        if rhImage != nil{
            rhImageNode = SKSpriteNode(texture: SKTexture(image: rhImage))
            rhImageNode.position = CGPoint(x: size.width/2 + thumbImage.size.width/2 - 7 + rhImage.size.width/2, y: 0)
            addChild(rhImageNode)
        }
        
        let surroundNode = SKSpriteNode()
        surroundNode.size = CGSize(width: 200, height: 50)
        addChild(surroundNode)
    }
    
    func addDeathSymbolOnLeft(){
        let node = getLabelNode(MPCGDGenome.deathSymbol)
        node.position = CGPoint(x: -size.width/2 - 5, y: 0)
        node.alpha = 0.7
        node.fontSize = 14
        addChild(node)
    }
    
    func addOffSymbolOnLeft(){
        let node = getLabelNode("Off")
        node.position = CGPoint(x: -size.width/2 - 10, y: 0)
        node.alpha = 0.8
        node.zRotation = CGFloat.pi / 2
        node.fontSize = 15
        node.fontColor = Colours.getColour(.antiqueWhite)
        addChild(node)
    }
    
    fileprivate func getLabelNode(_ text: String) -> SKLabelNode{
        let font = UIFontCache(name: "HelveticaNeue-Thin", size: 12)
        labelNode = SKLabelNode(font, Colours.getColour(.black))
        labelNode.text = text
        labelNode.verticalAlignmentMode = SKLabelVerticalAlignmentMode.center
        return labelNode
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if HKDisableUserInteractions { return }
        if let touch = touches.first {
            value = convertLocationToValue(touch.location(in: self).x)
            dragging = true
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if HKDisableUserInteractions { return }
        if !dragging { return }
        if let touch = touches.first {
            value = convertLocationToValue(touch.location(in: self).x)
            onDragCode?()
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if HKDisableUserInteractions { return }
        if !dragging { return }
        dragging = false
        onDragCode?()
        touchEndCode?()
    }
    
    fileprivate func convertLocationToValue(_ location: CGFloat) -> Float {
        let minX = Float(minimumTrack.position.x)
        let maxX = Float(maximumTrack.position.x)
        let loc = clamp(value: Float(location), lower: minX, upper: maxX)
        let val = map(value: loc, from: (minX, maxX), to: (minimumValue, maximumValue))
        return val
    }
    
    fileprivate func convertValueToLocation(_ value: Float) -> CGFloat {
        let minX = Float(minimumTrack.position.x)
        let maxX = Float(maximumTrack.position.x)
        let val = clamp(value: value, lower: minimumValue, upper: maximumValue)
        let loc = CGFloat(map(value: val, from: (minimumValue, maximumValue), to: (minX, maxX)))
        return loc
    }
    
    fileprivate func calculateDuration(from: CGFloat, to: CGFloat) -> TimeInterval {
        return TimeInterval(map(value: abs(to - from), from: (0, maximumTrack.position.x - minimumTrack.position.x), to: (0.2, 0.6)))
    }
    
    func changeColours(_ colour: UIColor){
        minimumTrack.color = colour
        maximumTrack.color = colour
        labelNode?.fontColor = colour
        lhLabelNode?.fontColor = colour
        rhLabelNode?.fontColor = colour
        minimumTrack.imageNode.texture = SKTexture(image: ImageUtils.getBlankImage(CGSize(width: size.width, height: 2), colour: colour))
        maximumTrack.imageNode.texture = SKTexture(image: ImageUtils.getBlankImage(CGSize(width: size.width, height: 2), colour: colour))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("Fatal Error: init(coder) not implemented!")
    }
}
