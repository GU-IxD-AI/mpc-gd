//
//  SpriteUtils.swift
//  Fask
//
//  Created by Simon Colton on 14/09/2015.
//  Copyright (c) 2015 Simon Colton. All rights reserved.
//

import Foundation
import SpriteKit

extension SKNode {
    // Recursively detach all children in hierarchy
    func detachChildren() {
        children.forEach{ if $0.children.count > 0 { $0.detachChildren() } }
        removeAllChildren()
    }

    // Detach this node from parent and then recursively detach all children in hierarchy
    func detachAll() {
        removeFromParent()
        detachChildren()
    }
}

class SpriteUtils{
    
    static func getRoundTextButtonSprite(_ buttonText: String, diameter: CGFloat, fillColour: UIColor, strokeColour: UIColor, strokeWidth: CGFloat) -> SKRoundButtonNode{
        let doubleSize = CGSize(width: (diameter * 2) + (strokeWidth * 2), height: (diameter * 2) + (strokeWidth * 2))
        UIGraphicsBeginImageContextWithOptions(doubleSize, false, 1)
        let context = UIGraphicsGetCurrentContext()
        let centre = CGPoint(x: diameter + strokeWidth, y: diameter + strokeWidth)
        DrawingShapes.fillCircleOnContext(context!, colour: fillColour, centre: centre, radius: diameter)
        DrawingShapes.strokeCircleOnContext(context!, colour: strokeColour, strokeWidth: strokeWidth, centre: centre, radius: diameter)
        let textRectSize = CGSize(width: diameter * 1.6, height: diameter * 1.6)
        let font = FontUtils.getFontToFillRect(buttonText, baseFont: Fonts.primaryFont, size: textRectSize)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        let sprite = SKRoundButtonNode()
        sprite.setImage(image!)
        sprite.size = CGSize(width: diameter, height: diameter)
        let textSprite = SKLabelNode(text: buttonText)
        textSprite.fontColor = strokeColour
        textSprite.fontSize = font.pointSize/2
        textSprite.fontName = font.fontName
        textSprite.verticalAlignmentMode = SKLabelVerticalAlignmentMode.center
        sprite.addChild(textSprite)
        return sprite
    }
    
    fileprivate class RoundedRectCacheItem {
        let size: CGSize
        let cornerRadius: CGFloat
        let fillColour: UIColor
        let borderColour: UIColor
        let strokeWidth: CGFloat
        let texture: SKTexture
        
        init(size: CGSize, cornerRadius: CGFloat, fillColour: UIColor, borderColour: UIColor, strokeWidth: CGFloat) {
            self.size = size
            self.cornerRadius = cornerRadius
            self.fillColour = fillColour
            self.borderColour = borderColour
            self.strokeWidth = strokeWidth
            
            let doubleSize = CGSize(width: (size.width * 2) + (strokeWidth * 2), height: (size.height * 2) + (strokeWidth * 2))
            UIGraphicsBeginImageContextWithOptions(doubleSize, false, 1)
            let context = UIGraphicsGetCurrentContext()
            let smallerRect = CGRect(x: 2, y: 2, width: doubleSize.width - 4, height: doubleSize.height - 4)
            DrawingShapes.fillRoundedRectOnContext(context!, rect: smallerRect, colour: fillColour, cornerRadius: cornerRadius)
            DrawingShapes.strokeRoundedRectOnContext(context!, rect: smallerRect, strokeWidth: strokeWidth, colour: borderColour, cornerRadius: cornerRadius)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            self.texture = SKTexture(image:image!)
        }
    }
    
    static fileprivate var roundedRectCache : [RoundedRectCacheItem] = []
    static fileprivate var roundedRectCacheHits = 0
        
    static func getRoundedRectSprite(_ size: CGSize, cornerRadius: CGFloat, fillColour: UIColor, borderColour: UIColor, strokeWidth: CGFloat) -> SKSpriteNode{
        for cacheItem in roundedRectCache {
            if cacheItem.size == size && cacheItem.cornerRadius == cornerRadius && cacheItem.fillColour == fillColour && cacheItem.borderColour == borderColour && cacheItem.strokeWidth == strokeWidth {
                roundedRectCacheHits += 1
                return SKSpriteNode(texture: cacheItem.texture, size: size)
            }
        }
        
        let newCacheItem = RoundedRectCacheItem(size: size, cornerRadius: cornerRadius, fillColour: fillColour, borderColour: borderColour, strokeWidth: strokeWidth)
        roundedRectCache.append(newCacheItem)
        return SKSpriteNode(texture: newCacheItem.texture, size: size)
    }
    
    static func getRoundedRectTextSprite(_ text: String, size: CGSize, font: UIFont, cornerRadius: CGFloat, fillColour: UIColor, strokeColour: UIColor, textColour: UIColor, strokeWidth: CGFloat, alignment: SKLabelVerticalAlignmentMode) -> SKSpriteNode{
        let image = getRoundedRectTextSpriteImage("", size: size, font: font, cornerRadius: cornerRadius, fillColour: fillColour, strokeColour: strokeColour, strokeWidth: strokeWidth)
        let sprite = SKSpriteNode(texture: SKTexture(image:image), size: size)
        let textSprite = SKLabelNode(text: text)
        textSprite.fontColor = textColour
        textSprite.fontName = font.fontName
        textSprite.fontSize = font.pointSize/2
        textSprite.verticalAlignmentMode = alignment
        sprite.addChild(textSprite)
        return sprite
    }

    static func getImageAndTextSprite(_ text: String, size: CGSize, font: UIFont, cornerRadius: CGFloat, textColour: UIColor, backgroundImage: UIImage!, alpha: CGFloat, fillColour: UIColor, alignment: SKLabelVerticalAlignmentMode) -> SKSpriteNode{
        let doubleSize = size * 2
        UIGraphicsBeginImageContextWithOptions(doubleSize, false, 1)
        let context = UIGraphicsGetCurrentContext()
        let smallerRect = CGRect(x: 0, y: 0, width: doubleSize.width, height: doubleSize.height)
        DrawingShapes.fillRoundedRectOnContext(context!, rect: smallerRect, colour: fillColour, cornerRadius: cornerRadius)
        ImageUtils.drawImageOntoContext(context!, image: backgroundImage.alpha(alpha))
//        DrawingText.addTextToContextCentredInRect(context!, font: font, text: text, colour: textColour, rect: CGRect(origin: CGPoint.zero, size: doubleSize))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        let sprite = SKSpriteNode(texture: SKTexture(image: image!), size: size)
        let textSprite = SKLabelNode(text: text)
        textSprite.fontColor = textColour
        textSprite.fontName = font.fontName
        textSprite.fontSize = font.pointSize/2
        textSprite.verticalAlignmentMode = alignment
        sprite.addChild(textSprite)
        return sprite
    }
    
    static func getRoundedRectTextSpriteImage(_ text: String, size: CGSize, font: UIFont, cornerRadius: CGFloat, fillColour: UIColor, strokeColour: UIColor, strokeWidth: CGFloat) -> UIImage{
        let doubleSize = CGSize(width: (size.width * 2) + (strokeWidth * 2), height: (size.height * 2) + (strokeWidth * 2))
        UIGraphicsBeginImageContextWithOptions(doubleSize, false, 1)
        let context = UIGraphicsGetCurrentContext()
        let smallerRect = CGRect(x: 2, y: 2, width: doubleSize.width - 4, height: doubleSize.height - 4)
        DrawingShapes.fillRoundedRectOnContext(context!, rect: smallerRect, colour: fillColour, cornerRadius: cornerRadius)
        if strokeWidth > 0{
            DrawingShapes.strokeRoundedRectOnContext(context!, rect: smallerRect, strokeWidth: strokeWidth, colour: strokeColour, cornerRadius: cornerRadius)            
        }
        DrawingText.addTextToContextCentredInRect(context!, font: font, text: text, colour: strokeColour, rect: CGRect(origin: CGPoint.zero, size: doubleSize))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
    
}
