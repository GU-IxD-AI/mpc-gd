//
//  Label.swift
//  Engine
//
//  Created by Simon Colton on 31/07/2016.
//  Copyright © 2016 Simon Colton. All rights reserved.
//

import Foundation
import SpriteKit

class Label: SKNode{
    
    var size: CGSize! = nil
    
    var textNode: SKLabelNode! = nil
    
    var boundingBox: SKSpriteNode! = nil
    
    fileprivate var col: UIColor! = nil
    
    var fontColor: UIColor!{
        get{
            return textNode.fontColor
        }
        set(newFontColor){
            textNode.fontColor = newFontColor
        }
    }
    
    fileprivate var tex: String! = nil
    
    var text: String!{
        get{
            return tex
        }
        set(newText){
            tex = newText
            if newText != nil{
                textNode.text = newText
                let col = textNode.fontColor
                calculateFont()
                textNode.fontColor = col
            }
            else{
                textNode.text = ""
            }
        }
    }
    
    fileprivate var minFS: CGFloat! = Fonts.smallFont.pointSize
    
    var minFontSize: CGFloat!{
        get{
            return minFS
        }
        set(newMinFS){
            maxFS = newMinFS
            calculateFont()
        }
    }
    
    fileprivate var maxFS: CGFloat = Fonts.primaryFont.pointSize
    
    var maxFontSize: CGFloat!{
        get{
            return maxFS
        }
        set(newMaxFS){
            maxFS = newMaxFS
            calculateFont()
        }
    }
    
    var verticalAlignmentMode: SKLabelVerticalAlignmentMode{
        get{
            return textNode.verticalAlignmentMode
        }
        set(newMode){
            textNode.verticalAlignmentMode = newMode
        }
    }
    
    var horizontalAlignmentMode: SKLabelHorizontalAlignmentMode{
        get{
            return textNode.horizontalAlignmentMode
        }
        set(newMode){
            textNode.horizontalAlignmentMode = newMode
        }
    }
    
    fileprivate var ital = false
    
    var italic: Bool{
        get{
            return ital
        }
        set(newItal){
            ital = newItal
            calculateFont()
        }
    }
    
    fileprivate var bol = false
    
    var bold: Bool{
        get{
            return bol
        }
        set(newBol){
            bol = newBol
            calculateFont()
        }
    }
    
    init(text: String, size: CGSize){
        super.init()
        self.tex = text
        self.size = size
        boundingBox = SKSpriteNode(texture: nil, size: size)
        //        boundingBox = SpriteUtils.getRoundedRectSprite(size, cornerRadius: 0, fillColour: UIColor.redColor(), borderColour: Colours.foreground, strokeWidth: 2)
        textNode = SKLabelNode(text: text)
        calculateFont()
        addChild(boundingBox)
        addChild(textNode)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func calculateFont(){
        var baseFont = UIFont.init(name: Fonts.primaryFont.familyName, size: Fonts.primaryFont.pointSize)!
        textNode.fontName = Fonts.primaryFont.familyName
        if bol && !ital{
            baseFont = UIFont.init(name: Fonts.boldFontName, size: Fonts.primaryFont.pointSize)!
            textNode.fontName = Fonts.boldFontName
        }
        if ital && !bol{
            baseFont = UIFont.init(name: Fonts.italicFontName, size: Fonts.primaryFont.pointSize)!
            textNode.fontName = Fonts.italicFontName
        }
        if ital && bol{
            baseFont = UIFont.init(name: Fonts.boldItalicFontName, size: Fonts.primaryFont.pointSize)!
            textNode.fontName = Fonts.boldItalicFontName
        }
        let font = FontUtils.getFontToFillRect(tex, baseFont: baseFont, size: boundingBox.size)
        textNode.fontSize = min(font.pointSize, maxFS)
        textNode.fontColor = Colours.foreground
    }
    
    @objc override func containsScenePoint(_ point: CGPoint) -> Bool {
        return boundingBox.containsScenePoint(point)
    }
}
