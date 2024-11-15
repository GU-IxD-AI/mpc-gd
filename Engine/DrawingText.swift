//
//  DrawingText.swift
//  Fask
//
//  Created by Simon Colton on 14/09/2015.
//  Copyright (c) 2018 ThoseMetamakers. All rights reserved.
//

import Foundation
import SpriteKit

class DrawingText{
    
    
    static func drawTextInImage(_ baseImage: UIImage, text: String, font: UIFont, colour: UIColor, position: CGPoint) -> UIImage{
        UIGraphicsBeginImageContextWithOptions(baseImage.size * 2, false, 1)
        let context = UIGraphicsGetCurrentContext()
        context!.translateBy(x: 0, y: baseImage.size.height);
        context!.scaleBy(x: 1.0, y: -1.0)
        context!.draw(baseImage.cgImage!, in: CGRect(x: 0, y: 0, width: baseImage.size.width * 2, height: baseImage.size.height * 2))
        
        context!.setShouldAntialias(true)
        context!.setStrokeColor(colour.cgColor)
        context!.setFillColor(colour.cgColor)
        
        context!.translateBy(x: 0, y: baseImage.size.height)
        context!.scaleBy(x: 1.0, y: -1.0)
        
        let attr = [NSAttributedStringKey.font: font, NSAttributedStringKey.foregroundColor: colour]
        text.draw(at: CGPoint(x: position.x * 2, y: position.y * 2), withAttributes: attr)
        
        let textOverlaidImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return textOverlaidImage!
    }
    
    static func drawTextInImageCentredXandY(_ baseImage: UIImage, text: String, font: UIFont, colour: UIColor, opaque: Bool) -> UIImage{
        UIGraphicsBeginImageContextWithOptions(baseImage.size, opaque, 1)
        let context = UIGraphicsGetCurrentContext()
        context!.translateBy(x: 0, y: baseImage.size.height);
        context!.scaleBy(x: 1.0, y: -1.0)
        context!.draw(baseImage.cgImage!, in: CGRect(x: 0, y: 0, width: baseImage.size.width, height: baseImage.size.height))
        
        context!.setShouldAntialias(true)
        context!.setStrokeColor(colour.cgColor)
        context!.setFillColor(colour.cgColor)
        
        context!.translateBy(x: 0, y: baseImage.size.height)
        context!.scaleBy(x: 1.0, y: -1.0)
        
        let textSize = DrawingText.textSize(text, font: font)
        let xPos = (baseImage.size.width - textSize.width)/2
        let yPos = (baseImage.size.height - textSize.height)/2
        
        let attr = [NSAttributedStringKey.font: font, NSAttributedStringKey.foregroundColor: colour]
        let position = CGPoint(x: xPos, y: yPos)
        text.draw(at: position, withAttributes: attr)
        
        let textOverlaidImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return textOverlaidImage!
    }
    
    
    static func drawTextInImageCentredX(_ baseImage: UIImage, text: String, yPos: CGFloat, font: UIFont, colour: UIColor) -> UIImage{
        UIGraphicsBeginImageContextWithOptions(baseImage.size, false, 1)
        let context = UIGraphicsGetCurrentContext()
        context!.translateBy(x: 0, y: baseImage.size.height);
        context!.scaleBy(x: 1.0, y: -1.0)
        context!.draw(baseImage.cgImage!, in: CGRect(x: 0, y: 0, width: baseImage.size.width, height: baseImage.size.height))
        
        context!.setShouldAntialias(true)
        context!.setStrokeColor(colour.cgColor)
        context!.setFillColor(colour.cgColor)
        
        context!.translateBy(x: 0, y: baseImage.size.height)
        context!.scaleBy(x: 1.0, y: -1.0)
        
        let textWidth = DrawingText.textSize(text, font: font).width
        let xPos = (baseImage.size.width - textWidth)/2
        
        let attr = [NSAttributedStringKey.font: font, NSAttributedStringKey.foregroundColor: colour]
        let position = CGPoint(x: xPos, y: yPos)
        text.draw(at: position, withAttributes: attr)
        
        let textOverlaidImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return textOverlaidImage!
    }
    
    static func textSize(_ text: String, font: UIFont) -> CGSize{
        let textSize = NSString(string: text).size(withAttributes: [NSAttributedStringKey.font: font])
        return textSize
    }
    
    static func addTextToContext(_ context: CGContext, font: UIFont, text: String, colour: UIColor, position: CGPoint) -> CGSize{
        let attr = [NSAttributedStringKey.font: font, NSAttributedStringKey.foregroundColor: colour]
        context.setShouldAntialias(true)
        context.setStrokeColor(colour.cgColor)
        context.setFillColor(colour.cgColor)
        text.draw(at: position, withAttributes: attr)
        return textSize(text, font: font)
    }
    
    static func addTextToContextCentredX(_ context: CGContext, font: UIFont, text: String, colour: UIColor, yPos: CGFloat, contextWidth: CGFloat){
        let attr = [NSAttributedStringKey.font: font, NSAttributedStringKey.foregroundColor: colour]
        context.setShouldAntialias(true)
        context.setStrokeColor(colour.cgColor)
        context.setFillColor(colour.cgColor)
        let textWidth = DrawingText.textSize(text, font: font).width
        let xPos = (contextWidth - textWidth)/2
        let position = CGPoint(x: xPos, y: yPos)
        text.draw(at: position, withAttributes: attr)
    }
    
    static func addTextToContextCentredInRect(_ context: CGContext, font: UIFont, text: String, colour: UIColor, rect: CGRect){
        let paraStyle = NSMutableParagraphStyle()
//        paraStyle.lineSpacing = 6.0
        paraStyle.alignment = NSTextAlignment.center
        let attr = [NSAttributedStringKey.font: font, NSAttributedStringKey.foregroundColor: colour, NSAttributedStringKey.paragraphStyle: paraStyle]
        let textHeight = FontUtils.textSize(text, font: font).height
        context.setShouldAntialias(true)
        context.setStrokeColor(colour.cgColor)
        context.setFillColor(colour.cgColor)
        let movedRect = CGRect(x: rect.origin.x, y: rect.origin.y + rect.height/2 - textHeight/2, width: rect.width, height: textHeight)
        text.draw(in: movedRect, withAttributes: attr)
    }


}
