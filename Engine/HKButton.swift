//
//  HKButton.swift
//  MPCGD
//
//  Created by Simon Colton on 02/01/2017.
//  Copyright © 2017 ThoseMetamakers. All rights reserved.
//

import Foundation
import SpriteKit

class HKButton: HKComponent{
    
    static var lock: HKButton! = nil
    
    static let highlightColour = Colours.getColour(.orange).withAlphaComponent(0.3)
    
    var bestLabel: SKLabelNode! = nil
    
    var isHot = false
    
    var tappedAt = CGPoint.zero
    
    var tapCode: (() -> ())! = nil
    
    var onTapStartCode: (() -> ())! = nil
    
    var onTouchCode: (() -> ())! = nil
    
    var onTouchesMovedCode: ((CGVector) -> ())! = nil
    
    var onDragEndCode: (() -> ())! = nil
    
    var hkTapRect: SKSpriteNode! = nil
    var hkImage: HKImage
    
    var highlight: SKSpriteNode! = nil
    
    var tempHighlight: SKSpriteNode! = nil
    
    var highlightSize: CGSize! = nil
    
    var enabled = true{
        didSet(newMinimumValue) {
            if !enabled{
                //hkImage.alpha = 0.5
            }
            else{
                hkImage.alpha = 1
            }
        }
    }

    var useTempHighlight = false

    static let defaultScaleAction = SKAction.sequence([
        HKEasing.scaleTo(1.15, duration: 0.1, easingFunction: BackEaseOut),
        HKEasing.scaleTo(1, duration: 0.1, easingFunction: BackEaseOut)])

    var scaleAction = HKButton.defaultScaleAction

    func setScaleActionInterval(_ i: ClosedRange<CGFloat>) {
        scaleAction = SKAction.sequence([
            HKEasing.scaleTo(i.upperBound, duration: 0.1, easingFunction: BackEaseOut),
            HKEasing.scaleTo(i.lowerBound, duration: 0.1, easingFunction: BackEaseOut)
            ])
    }
    
    init(image: UIImage, useTempHighlight: Bool = false){
        self.useTempHighlight = useTempHighlight
        hkImage = HKImage(image: image)
        super.init()
        addChild(hkImage)
    }

    init(image: UIImage, dilateTapBy: CGSize, useTempHighlight: Bool = false) {
        self.useTempHighlight = useTempHighlight
        let tapSize = CGSize(width: image.size.width * dilateTapBy.width, height: image.size.height * dilateTapBy.height)
        //let tapColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.001)
        // Colorize for debugging ... 
        let tapColor = UIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 0.001)
        hkImage = HKImage(image: image)
        hkTapRect = SKSpriteNode(color: tapColor, size: tapSize)
        super.init()
        hkTapRect.addChild(hkImage)
        addChild(hkTapRect)
    }

    override func contains(_ p: CGPoint) -> Bool {
        var size = hkImage.size
        var anchor = hkImage.anchorPoint
        if hkTapRect != nil {
            size = hkTapRect.size
            anchor = hkTapRect.anchorPoint
        }
        let r = CGRect(x: 0.0, y: 0.0, width: size.width, height: size.height).offsetBy(dx: -size.width * anchor.x, dy: -size.height * anchor.y)
//        print("\(r) : \(p)")
        return r.contains(p)
    }
    
    func showTempHighlight(){
        if useTempHighlight && tempHighlight == nil && highlightSize != nil{
            tempHighlight = SKSpriteNode(color: HKButton.highlightColour, size: highlightSize)
            addChild(tempHighlight)
            tempHighlight.zPosition = hkImage.imageNode.zPosition - 1
        }
    }
    
    func removeTempHighlight(){
//        if useTempHighlight{
            if tempHighlight != nil{
                tempHighlight.removeFromParent()
            }
            tempHighlight = nil            
//        }
    }
    
    func showHighlight(){
        if highlight == nil && highlightSize != nil{
            highlight = SKSpriteNode(color: HKButton.highlightColour, size: highlightSize)
            addChild(highlight)
            highlight.zPosition = hkImage.imageNode.zPosition - 1
        }
    }
    
    func removeHighlight(){
        if highlight != nil{
            highlight.removeFromParent()
        }
        highlight = nil
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard HKDisableUserInteractions == false && HKButton.lock === nil else { return }
        guard touches.count == 1 && self.enabled && alpha == 1.0 else { return }
        guard let touch = touches.first else { return }

        if touch.tapCount <= 1 {
            HKButton.lock = self
            isHot = true
            showTempHighlight()
            run(scaleAction, completion: { [unowned self] () -> () in
                self.removeTempHighlight()
                self.isHot = false
                HKButton.lock = nil
            })
            onTouchCode?()
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard HKDisableUserInteractions == false && self.isHot else { return }
        guard let touch = touches.first else { return }
        tappedAt = touch.location(in: self)
        onTapStartCode?()
        tapCode?()
    }
}
