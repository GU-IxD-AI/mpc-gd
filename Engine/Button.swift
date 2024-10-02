//
//  Button.swift
//  Engine
//
//  Created by Simon Colton on 28/07/2016.
//  Copyright © 2016 Simon Colton. All rights reserved.
//

import Foundation
import SpriteKit

class Button: SKNode{

    static let opaqueButtonTexture = Button.getButtonTexture(Colours.background)
    
    static let buttonTexture = Button.getButtonTexture(Colours.transBackground)
    
    static let wideButtonTexture = Button.getWideButtonTexture(Colours.transBackground)
    
    static let wideOpaqueButtonTexture = Button.getWideButtonTexture(Colours.background)
    
    static var texturesHash = Dictionary<UIColor, SKTexture>()
    
    static var wideTexturesHash = Dictionary<UIColor, SKTexture>()
    
    var backgroundNode: SKSpriteNode! = nil
    
    var textNode: AutoSizedLabelNode! = nil
    
    var iconNode: SKSpriteNode! = nil
    
    var fs: CGFloat! = nil
    
    var fontSize: CGFloat!{
        get{
            return fs
        }
        set(newFontSize){
            fs = newFontSize
            textNode.fontSize = newFontSize
        }
    }

    fileprivate var col = Colours.background
    
    var colour: UIColor!{
        get{
            return col
        }
        set(newColour){
            col = newColour
            if wid {
                backgroundNode.texture = Button.getWideButtonTexture(col)
            } else {
                backgroundNode.texture = Button.getButtonTexture(col)
            }
        }
    }
    
    override var frame: CGRect{
        return CGRect(origin: CGPoint(x: position.x - LAF.buttonSize.width/2, y: position.y + LAF.buttonSize.height/2), size: LAF.buttonSize)
    }
    
    fileprivate var wid = false
    
    var isWide: Bool{
        get{
            return wid
        }
        set(newIsWide){
            if wid != newIsWide{
                wid = newIsWide
                removeAllChildren()
                if wid{
                    addWideBackgroundNode()
                    if tex != nil{
                        addTextNode(tex)
                    }
                }
                else{
                    addBackgroundNode()
                    if tex != nil{
                        addTextNode(tex)
                    }
                }
            }
        }
    }
    
    fileprivate var tex: String! = nil
    
    var text: String!{
        get{
            return tex
        }
        set(newText){
            if newText == nil && textNode != nil{
                textNode.removeFromParent()
                textNode = nil
            }
            else if newText != tex{
                if textNode != nil{
                    textNode.removeFromParent()                    
                }
                addTextNode(newText)
            }
            tex = newText
        }
    }
    
    fileprivate var opaque = false
    
    var isOpaque: Bool{
        get{
            return opaque
        }
        set(newIsOpaque){
            if newIsOpaque{
                if isWide{
                    backgroundNode.texture = Button.wideOpaqueButtonTexture
                }
                else{
                    backgroundNode.texture = Button.opaqueButtonTexture
                }
            }
            else{
                if isWide{
                    backgroundNode.texture = Button.wideButtonTexture
                }
                else{
                    backgroundNode.texture = Button.buttonTexture
                }
                
            }
        }
    }
    
    var icn: UIImage! = nil
    
    var icon: UIImage{
        get{
            return icn
        }
        set(newIcn){
            icn = newIcn
            if textNode != nil{
                textNode.removeFromParent()
            }
            if iconNode != nil{
                iconNode.removeFromParent()
            }
            iconNode = SKSpriteNode(texture: SKTexture(image: newIcn), size: LAF.buttonSize)
            addChild(iconNode)
        }
    }
    
    override init(){
        super.init()
        addBackgroundNode()
    }
    
    init(text: String){
        super.init()
        tex = text
        addBackgroundNode()
        addTextNode(text)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addBackgroundNode(){
        backgroundNode = SKSpriteNode(texture: Button.buttonTexture, size: LAF.buttonSize)
        //addChild(backgroundNode)
    }
    
    func addWideBackgroundNode(){
        backgroundNode = SKSpriteNode(texture: Button.wideButtonTexture, size: LAF.wideButtonSize)
        addChild(backgroundNode)
    }
    
    func addTextNode(_ text: String){
        var size = LAF.buttonSize * 0.8
        var oneLine = false
        if wid{
            size = LAF.wideButtonSize * 0.9
            oneLine = true
        }
        textNode = AutoSizedLabelNode(text: text, size: size, oneLine: oneLine)
        textNode.verticalAlignmentMode = SKLabelVerticalAlignmentMode.center
        if wid{
            textNode.fontSize = Fonts.wideButtonFontSize
        }
        addChild(textNode)
    }
    
    static func getButtonTexture(_ backgroundColour: UIColor) -> SKTexture{
        if let retrievedTexture = texturesHash[backgroundColour]{
            return retrievedTexture
        }
        else{
            let texture = getTexture(backgroundColour, size: LAF.buttonSize)
            texturesHash[backgroundColour] = texture
            return texture
        }
    }
    
    static func getWideButtonTexture(_ backgroundColour: UIColor) -> SKTexture{
        if let retrievedTexture = wideTexturesHash[backgroundColour]{
            return retrievedTexture
        }
        else{
            let texture = getTexture(backgroundColour, size: LAF.wideButtonSize)
            texturesHash[backgroundColour] = texture
            return texture
        }
    }
    
    static func getTexture(_ backgroundColour: UIColor, size: CGSize) -> SKTexture{
        let doubleSize = CGSize(width: (size.width * 2) + (LAF.buttonStrokeWidth * 2), height: (size.height * 2) + (LAF.buttonStrokeWidth * 2))
        UIGraphicsBeginImageContextWithOptions(doubleSize, false, 1)
        let context = UIGraphicsGetCurrentContext()
        let smallerRect = CGRect(x: 6, y: 3, width: doubleSize.width - 12, height: doubleSize.height - 6)
//        DrawingShapes.fillRoundedRectOnContext(context!, rect: smallerRect, colour: backgroundColour, cornerRadius: LAF.cornerRadius)
        DrawingShapes.strokeRoundedRectOnContext(context!, rect: smallerRect, strokeWidth: 3, colour: Colours.foreground, cornerRadius: LAF.cornerRadius)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return SKTexture(image:image!)
    }
    
    @objc override func containsScenePoint(_ point: CGPoint) -> Bool {
        let localPoint: CGPoint
        if parent != nil && scene != nil {
            localPoint = backgroundNode.parent!.convert(point, from: scene!)
        }
        else {
            localPoint = point
        }
        return backgroundNode.frame.scaledFromCentre(LAF.buttonTapAreaScale).contains(localPoint)
    }
    
}
