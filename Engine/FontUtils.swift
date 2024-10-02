//
//  FontUtils.swift
//  Fask
//
//  Created by Simon Colton on 12/09/2015.
//  Copyright (c) 2015 Simon Colton. All rights reserved.
//

import Foundation
import SpriteKit

class FontUtils{
    
    static func getFontToFillRect(_ withString: String, baseFont: UIFont, size: CGSize) -> UIFont{
        
        var textSize = CGSize(width: 0, height: 0)
        var font = UIFontCache(name: baseFont.fontName, size: 1)!
        while textSize.width < size.width && textSize.height < size.height{
            font = UIFontCache(name: baseFont.fontName, size: font.pointSize + 1)!
            textSize = FontUtils.textSize(withString, font: font)
        }
        font = UIFontCache(name: baseFont.fontName, size: font.pointSize - 1)!
        return font
    }
    
    static func textSize(_ text: String, font: UIFont) -> CGSize{
        let textSize = NSString(string: text).size(withAttributes: [NSAttributedStringKey.font: font])
        return textSize
    }
}
