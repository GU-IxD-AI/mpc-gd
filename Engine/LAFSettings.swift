//
//  LAFSettings.swift
//  Engine
//
//  Created by Simon Colton on 12/10/2015.
//  Copyright © 2015 Simon Colton. All rights reserved.
//

import Foundation
import SpriteKit

class LAFSettings{
    
    static let appName = "Let It Snow"
    
    static let initialisingText = "Initialising..."
    
    static let roundedRectCornerRadius = CGFloat(20)
    
    static let nonPhysicsScrollMomentum: CGFloat = 0.90 // must be between 0 and 1, higher = keeps scrolling for longer after lifting finger
    
    static let nonPhysicsScrollBounce: CGFloat = 0.25 // must be between 0 and 1, higher = more bouncy
    
    static let nonPhysicsScrollStopThreshold: CGFloat = 0.2 // scrolling stops when it goes below this speed
    
    static let longTapTime = Double(0.85)
    
    static let getScreenshotText = "Please use the camera button to get a screenshot, after which you can save the fascinator"
    
    static let enterNameText = "Please enter the name of your fascinator"
    
    static let enterPresetNameText = "Please enter the name of the preset"
    
    static let alertTextSize = CGFloat(14)
    
    static let alertTextFont : UIFont = {
        #if os(iOS)
            return UIFont.preferredFont(forTextStyle: UIFontTextStyle.body).withSize(LAFSettings.alertTextSize)
        #elseif os(OSX)
            return NSFont.messageFontOfSize(alertTextSize)
        #endif
    }()
    
    static let touchRadius: CGFloat = 30
    
    static var wallOffScreenNess: (CGFloat, CGFloat) = (3, 3)
    
    // ⚠️ WARNING!!! WARNING!!! WARNING!!! ⚠️
    // Changing this WILL change the gameplay of existing games and will probably break the UI!!!
    // The standard scene size -- set to be the same size as the iPod Touch screen
    static let standardSceneSize = CGSize(width: 320, height: 568)
}
