//
//  Images.swift
//  Beeee
//
//  Created by Simon Colton on 03/07/2015.
//  Copyright (c) 2015 Simon Colton. All rights reserved.
//

import Foundation
import SpriteKit

struct Backgrounds{
    
    static var backgrounds: [UIImage] = []
    
    static func loadBackgrounds(_ imageSize: CGSize){
        for b in 0...13{
            Backgrounds.addBackground(b, imageSize: imageSize)
        }
    }
    
    static func addBackground(_ b: Int, imageSize: CGSize){
        let bgName = "background\(b).jpg"
        Backgrounds.backgrounds.append(ImageUtils.getImageScaledToSize(UIImage(named: bgName)!, size: imageSize))
    }
    
}
