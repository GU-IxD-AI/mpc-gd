//
//  LAF.swift
//  Engine
//
//  Created by Simon Colton on 11/06/2016.
//  Copyright © 2016 Simon Colton. All rights reserved.
//

import Foundation
import SpriteKit

class LAF{
    
    // Fascinator settings
    
    static let ballFadeInDuration : Double = 0.2
    static let ballFadeOutDuration : Double = 0.5
    static let ballScaleDuration : Double = 0.2
    
    static let ballSmallThreshold : CGFloat = 5
    static let ballLargeThreshold : CGFloat = 10
    static let ballSmallRingWidth : CGFloat = 2
    static let ballLargeRingWidth : CGFloat = 3
    
    static var pauseTimerInSec : Int = 0
    static let pauseSlowDownTimeInSec : CGFloat = 0.5
    static let pauseSlowDownSteps : Int = 5
    
    static let hudBarHeight: CGFloat = 5
    static let hudVerticalOffset: CGFloat = LAF.getHUDVerticalOffset()
    static let hudOuterMargin: CGFloat = 5
    static let hudVertSpaceBetweenBars: CGFloat = 3
    static let hudHorizSpaceBetweenPills: CGFloat = 3
    static let hudBackgroundAlpha: CGFloat = 0.5
    static let hudPillBackgroundAlpha: CGFloat = 0.25
    
    static let numChannelsPerSoundEffect : Int = 4
    
    static let touchRadius: CGFloat = 30
    
    static let restartFadeOutDuration: Double = 0.5
    
    static let touchTapThreshold: CGFloat = 5
    
    static let springMaxThickness: CGFloat = 6
    static let springMinThickness: CGFloat = 3
    static let springLengthAtMinThickness: CGFloat = 30
    static let springThicknessMult = LAF.springMinThickness * LAF.springLengthAtMinThickness // so thickNessMult / lengthAtMinThickness == minThickness
    
    // Set this to 0 to disable the visual fill effect
    // Solid physics bodies are still created regardless of this
    static let controllerFillAlpha: CGFloat = 0.2
    
    // ⚠️ WARNING!!! WARNING!!! WARNING!!! ⚠️
    // Changing this WILL change the gameplay of existing games and will probably break the UI!!!
    // The standard scene size -- set to be the same size as the iPod Touch screen
    static let standardSceneSize = CGSize(width: 320, height: 568)
    
    // Use this to determine the optimal resolution to render images for display on screen
    static var screenPixelsPerScenePoint : CGFloat = 2
    
    // Rectangles
    
    static var cornerRadius = CGFloat(10)
    
    static var messageSize = CGSize(width: 200, height: 200)
    
    static var buttonTapAreaScale = CGFloat(1.1)
    
    static var menuSize = LAF.getMenuSize()
    
    // On-screen dimensions
    
    static var scrollBarHeightProportion = CGFloat(0.1)
    
    static var scrollBarWidth = CGFloat(5)
    
    static var mainLabelWidthProportion = CGFloat(0.9)
    
    static var buttonSize: CGSize! = LAF.getButtonSize()
    
    static var mainBorder = LAF.getMainBorder()
    
    static var wideButtonSize: CGSize! = LAF.getWideButtonSize()
    
    static var toolTipWidthProportion = CGFloat(0.75)
    
    static var toolTipHeightProportion = CGFloat(0.1)
    
    static var toolTipYOffset = CGFloat(100)
    
    static var buttonStrokeWidth = CGFloat(2)
    
    // WAITING
    
    static var maxGameTime = Double(300)
    
    static var endGameWaitDuration = Double(1)
    
    static var gameEndMusicWaitDuration = Double(5)
    
    static var longPressTime = Double(0.8)
    
    // ANIMATIONS
    
    static var scrollSlowDownProportion = CGFloat(0.9)
    
    // Tool tips
    
    static var toolTipFlyInDuration = Double(0.1)
    
    static var toolTipFlyOutDuration = Double(0.1)
    
    static var baseCampButtonMoveDuration = Double(0.3)
    
    static var editabilityFlyInDuration = Double(0.25)
    
    // ToggleBuittons
    
    static var toggleDuration = Double(0.2)
    
    // Switching screens
    
    static var switchScreenFadeInDuration = Double(0.2)
    
    static var switchScreenFadeOutDuration = Double(0.2)
    
    // Navigation side bar
    
    static var sideBarAppearDuration = Double(0.2)
    
    static var sideBarDisappearDuration = Double(0.2)
    
    // Menus
    
    static var subMenuExpandDuration = Double(0.5)
    
    // ChangerHistory widget
    
    static var changerHistoryWidgetSpaceMakingDuration = Double(0.3)
    
    static var changerHistoryWidgetDuplicateMoveDuration = Double(0.3)
    
    static var changerHistoryWidgetFlyUpDuration = Double(0.2)
    
    static var changerHistoryWidgetFlyDownDuration = Double(0.2)
    
    // Changer widget
    
    static var changerWidgetFadeOutDuration = Double(0.2)
    
    static var changerWidgetFadeInDuration = Double(0.5)
    
    static var changerWidgetSliderMoveDuration = Double(0.4)
    
    static var changerWidgetSliderHandlerScale = CGFloat(0.8)
    
    static var changerWidgetBarHeightProportion = CGFloat(0.2)
    
    // Icon widget
    
    static var iconWidgetDropDuration = Double(0.5)
    
    // ICON movements
    
    static var dialBallMovementDuration = Double(0.5)
    
    static var dialBallFadeInDuration = Double(0.5)
    
    static var dialBallWaitDuration = Double(0.5)
    
    static var dialBallFadeOutDuration = Double(0.5)
    
    static var dialCollisionDuration = Double(0.5)
    
    static var dialCollisionWaitDuration = Double(1.0)
    
    static var dialControlBallFadeInDuration = 0.2
    
    static var dialControlBallFadeOutDuration = 0.2
    
    static var dialControlBallMoveDuration = 0.5
    
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
    
    static func getHUDVerticalOffset() -> CGFloat{
        let device = UIDevice.current.model
        if device.contains("iPhone"){
            return 17
        }
        else if device.contains("iPad"){
            return 17
        }
        else if device.contains("iPod"){
            return 12
        }
        return 17
    }
    
    static func getMainBorder() -> CGFloat{
        let device = UIDevice.current.model
        if device.contains("iPod"){
            return CGFloat(16)
        }
        else{
            return CGFloat(17)
        }
    }
    
    static func getMenuSize() -> CGSize{
        let device = UIDevice.current.model
        if device.contains("iPad"){
            return CGSize(width: 300, height: 300)
        }
        else{
            return CGSize(width: 250, height: 250)
        }
        
    }
}
