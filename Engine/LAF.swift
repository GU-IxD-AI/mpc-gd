//
//  LAF.swift
//  Engine
//
//  Created by Simon Colton on 11/06/2016.
//  Copyright © 2016 ThoseMetamakers. All rights reserved.
//

import Foundation
import SpriteKit

class LAF{
    
    // Fascinator settings
    
    static let ballFadeInDuration : Double = 0.2
    static let ballFadeOutDuration : Double = 0.5
    static let ballScaleDuration : Double = 0.2
    
    static let numChannelsPerSoundEffect : Int = 4
    
    static let springMaxThickness: CGFloat = 6
    static let springMinThickness: CGFloat = 3
    static let springLengthAtMinThickness: CGFloat = 30
    static let springThicknessMult = LAF.springMinThickness * LAF.springLengthAtMinThickness // so thickNessMult / lengthAtMinThickness == minThickness
    
    // Set this to 0 to disable the visual fill effect
    // Solid physics bodies are still created regardless of this
    static let controllerFillAlpha: CGFloat = 0.2
    
    static var wallOffScreenNess: (CGFloat, CGFloat) = (3, 3)
    
    // ⚠️ WARNING!!! WARNING!!! WARNING!!! ⚠️
    // Changing this WILL change the gameplay of existing games and will probably break the UI!!!
    // The standard scene size -- set to be the same size as the iPod Touch screen
    static let standardSceneSize = CGSize(width: 320, height: 568)
    
    // Rectangles
    
    static var cornerRadius = CGFloat(10)
    
    static var buttonTapAreaScale = CGFloat(1.1)
    
    // On-screen dimensions
    
    static var buttonSize: CGSize! = LAF.getButtonSize()
    
    static var wideButtonSize: CGSize! = LAF.getWideButtonSize()
    
    static var buttonStrokeWidth = CGFloat(2)
    
    // WAITING
    
    static var maxGameTime = Double(300)
    
    static func getButtonSize() -> CGSize{
        let device = UIDevice.current.model
        if device.contains("iPhone"){
            return CGSize(width: 50, height: 50)
        }
        else if device.contains("iPad"){
            return CGSize(width: 50, height: 50)
        }
        else if device.contains("iPod"){
            return CGSize(width: 52, height: 52)
        }
        return CGSize(width: 50, height: 50)
    }
    
    static func getWideButtonSize() -> CGSize{
        let device = UIDevice.current.model
        if device.contains("iPhone"){
            return CGSize(width: 120, height: 50)
        }
        else if device.contains("iPad"){
            return CGSize(width: 120, height: 50)
        }
        else if device.contains("iPod"){
            return CGSize(width: 120, height: 55)
        }
        return CGSize(width: 120, height: 50)
    }
}
