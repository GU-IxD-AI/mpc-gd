//
//  UIImageExtension.swift
//  Engine
//
//  Created by Simon Colton on 18/11/2015.
//  Copyright © 2015 Simon Colton. All rights reserved.
//

import Foundation
import SpriteKit

extension UIImage{
    
    func alpha(_ value:CGFloat) -> UIImage
    {
        UIGraphicsBeginImageContextWithOptions(self.size, false, 0.0)
        
        let ctx = UIGraphicsGetCurrentContext()
        let area = CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height)
        
        ctx!.scaleBy(x: 1, y: -1)
        ctx!.translateBy(x: 0, y: -area.size.height)
        ctx!.setBlendMode(CGBlendMode.multiply)
        ctx!.setAlpha(value)
        ctx!.draw(self.cgImage!, in: area)
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
}
