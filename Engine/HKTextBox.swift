//
//  HKTextBox.swift
//  MPCGD
//
//  Created by Simon Colton on 27/01/2017.
//  Copyright © 2017 ThoseMetamakers. All rights reserved.
//

import Foundation
import SpriteKit

class HKTextBox: HKComponent{
    
    let size: CGSize
    
    var placeholder: String
    
    let font: UIFont
    
    let textColour: UIColor
    
    let backgroundColour: UIColor
    
    let borderColour: UIColor
    
    let cursorColour: UIColor
    
    let borderWidth: CGFloat
    
    var backingNode: SKSpriteNode! = nil
    
    var textNode: SKLabelNode! = nil
    
    var heavyFirst: Bool = false
    
    var alternativeLabelGenerator: ((String, Bool) -> (HKComponent, CGFloat))! = nil
    
    var cursorNode = SKSpriteNode()
    
    let cursorWidth: CGFloat
    var maxCharacters: Int = 30
    
    var blink = SKAction.sequence([SKAction.wait(forDuration: 0.4), SKAction.fadeOut(withDuration: 0.3), SKAction.wait(forDuration: 0.1), SKAction.fadeIn(withDuration: 0.2)])
    
    init(size: CGSize, placeholder: String, font: UIFont, textColour: UIColor = UIColor.black, backgroundColour: UIColor = UIColor.white, borderColour: UIColor = UIColor.black, borderWidth: CGFloat = 2, cornerRadius: CGFloat = 17, cursorColour: UIColor = UIColor.black, cursorWidth: CGFloat = 3){
        self.size = size
        self.placeholder = placeholder
        self.font = font
        self.textColour = textColour
        self.backgroundColour = backgroundColour
        self.borderColour = borderColour
        self.borderWidth = borderWidth
        self.cursorColour = cursorColour
        self.cursorWidth = cursorWidth
        super.init()
        backingNode = SpriteUtils.getRoundedRectSprite(size, cornerRadius: cornerRadius, fillColour: backgroundColour, borderColour: borderColour, strokeWidth: borderWidth)
        textNode = SKLabelNode(text: placeholder)
        textNode.fontName = font.familyName
        textNode.fontSize = font.pointSize - 10
        textNode.fontColor = textColour
        textNode.verticalAlignmentMode = .center
        self.addChild(backingNode)
        backingNode.addChild(textNode)
        let textHeight = FontUtils.textSize("A", font: font).height
        cursorNode.size = CGSize(width: cursorWidth, height: textHeight)
        cursorNode.color = cursorColour
        addChild(cursorNode)
    }
    
    func startCursorBlinking(){
        cursorNode.run(blink, completion: {
            self.startCursorBlinking()
        })
    }
    
    func stopCursor(){
        cursorNode.removeAllActions()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func respondToKeyPress(_ key: String){
        let oldText = textNode.text!
        if key.first != nil && oldText.count >= maxCharacters {
            return
        }
        var s = textNode.text!
        if placeholder.count > 0 && s == placeholder{
            // Prevent leading space characters
            if key == " " {
                return
            }
            s = ""
            placeholder = ""
            textNode.fontSize = font.pointSize
        }

        // Prevent leading/trailing space characters
        if key == " " {
            if s.count == 0 {
                return
            }
            if s.last == " " {
                return
            }
        }
        
        if key.first == nil{
            if s.count > 0 {
                textNode.text = String(s[s.startIndex..<s.index(s.startIndex, offsetBy: s.count - 1)])
            }
        }
        else{
            textNode.text = s + key
        }
        if alternativeLabelGenerator != nil{
            let (comp, totalWidth) = alternativeLabelGenerator(textNode.text!, heavyFirst)
            if totalWidth < size.width{
                backingNode.removeAllChildren()
                backingNode.addChild(comp)
                cursorNode.position.x = totalWidth/2 + 1
            }
            else{
                textNode.text = oldText
            }
        }
        else{
            let totalWidth = FontUtils.textSize(textNode.text!, font: font).width
            if totalWidth > size.width{
                textNode.text = oldText
            }
            else{
                cursorNode.position.x = totalWidth/2 + 1
            }
        }
    }
    
    func setColour(_ colour: UIColor){
        cursorNode.color = colour
        textNode.fontColor = colour
    }
    
    func reset(){
        backingNode.removeAllChildren()
        backingNode.addChild(textNode)
        textNode.text = placeholder
        textNode.fontSize = font.pointSize - 10
        cursorNode.position.x = 0
        cursorNode.removeAllActions()
        startCursorBlinking()
    }
    
}
