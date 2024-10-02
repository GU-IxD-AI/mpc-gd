//
//  Fonts.swift
//  Fask
//
//  Created by Simon Colton on 12/09/2015.
//  Copyright (c) 2015 Simon Colton. All rights reserved.
//

import Foundation
import SpriteKit

class Fonts{
    
    // See http://iosfonts.com for all the fonts
    
    static let fontName = "Helvetica"
    
    static let italicFontName = "Helvetica-Oblique"
    
    static let boldFontName = "Helvetica-Bold"
    
    static let boldItalicFontName = "Helvetica-BoldOblique"
    
    static let primaryFont : UIFont! = UIFontCache(name: fontName, size: 35)!
    
    static let wideButtonFontSize: CGFloat = 20
    
    static let buttonFontMaxSize: CGFloat = 15
    
    static let midFont : UIFont! = UIFontCache(name: fontName, size: 25)!
    
    static let smallFont : UIFont! = UIFontCache(name: fontName, size: 15)!
    
}
