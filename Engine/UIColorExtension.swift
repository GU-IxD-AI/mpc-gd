//
//  UIColorExtension.swift
//  Engine
//
//  Created by Simon Colton on 09/10/2015.
//  Copyright © 2015 Simon Colton. All rights reserved.
//

import Foundation
import SpriteKit

extension UIColor {
    
    func getRGBA() -> (CGFloat, CGFloat, CGFloat, CGFloat) {
        var fr: CGFloat = 0
        var fg: CGFloat = 0
        var fb: CGFloat = 0
        var fa: CGFloat = 0
        
        getRed(&fr, green: &fg, blue: &fb, alpha: &fa)
        
        return (fr, fg, fb, fa)
    }
    
    func getHSBA() -> (CGFloat, CGFloat, CGFloat, CGFloat) {
        
        var fh: CGFloat = 0
        var fs: CGFloat = 0
        var fb: CGFloat = 0
        var fa: CGFloat = 0
        
        #if os(OSX)
            let c = colorUsingColorSpaceName(NSCalibratedRGBColorSpace)
            c!.getHue(&fh, saturation: &fs, brightness: &fb, alpha: &fa)
        #elseif os(iOS)
            getHue(&fh, saturation: &fs, brightness: &fb, alpha: &fa)
        #endif
        
        return (fh, fs, fb, fa)
    }
    
    func getHue() -> CGFloat {
        return getHSBA().0
    }
    
    func lighter(by percentage: CGFloat=30.0) -> UIColor? {
        return self.adjust(by: abs(percentage) )
    }
    
    func darker(by percentage:CGFloat=30.0) -> UIColor? {
        return self.adjust(by: -1 * abs(percentage) )
    }
    
    func adjust(by percentage:CGFloat=30.0) -> UIColor? {
        var r:CGFloat=0, g:CGFloat=0, b:CGFloat=0, a:CGFloat=0;
        if(self.getRed(&r, green: &g, blue: &b, alpha: &a)){
            return UIColor(red: min(r + percentage/100, 1.0),
                           green: min(g + percentage/100, 1.0),
                           blue: min(b + percentage/100, 1.0),
                           alpha: a)
        }else{
            return nil
        }
    }
}
